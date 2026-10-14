import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';

class FakeServer implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  FutureOr<ResponseBody> Function(RequestOptions)? handler;
  Object body = <String, dynamic>{};
  int status = 200;
  static ResponseBody response(Object body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler == null ? response(body, status) : await handler!(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final productJson = {
    'id': 'product-1',
    'name': 'Mesmo nome',
    'brand': 'Marca',
    'categoryId': 'category-1',
    'category': 'Frutas',
    'imageUrl': '',
    'price': 10,
    'description': 'Descrição real',
  };
  Map<String, dynamic> cartBody({int quantity = 1}) => {
    'items': quantity == 0
        ? []
        : [
            {
              'product': productJson,
              'quantity': quantity,
              'subtotal': quantity * 10,
            },
          ],
    'itemCount': quantity,
    'total': quantity * 10,
  };
  late FakeServer authServer;
  late FakeServer server;
  late AuthService auth;
  late StoreService api;
  late ShoppingCartController cart;

  Future<void> login(String id) async {
    authServer.body = {
      'user': {'id': id, 'name': id, 'email': '$id@example.com'},
      'tokens': {
        'accessToken': 'token-$id',
        'tokenType': 'Bearer',
        'expiresIn': 3600,
      },
    };
    await auth.login(email: '$id@example.com', password: 'Senha@1');
  }

  setUp(() async {
    authServer = FakeServer();
    server = FakeServer();
    auth = AuthService(
      dio: Dio(BaseOptions(baseUrl: AuthService.baseUrl))
        ..httpClientAdapter = authServer,
    );
    api = StoreService(
      auth,
      dio: Dio(BaseOptions(baseUrl: AuthService.baseUrl))
        ..httpClientAdapter = server,
    );
    await login('a');
    cart = ShoppingCartController(api);
  });
  tearDown(() {
    cart.dispose();
    auth.dispose();
  });

  test('Profile uses the current bearer and maps the user id', () async {
    server.body = {'id': 'a', 'name': 'Ana', 'email': 'a@example.com'};
    final user = await api.getMe();
    expect(user.id, 'a');
    expect(user.nome, 'Ana');
    expect(server.requests.single.headers['Authorization'], 'Bearer token-a');
    expect(server.requests.single.uri.path, '/api/v1/users/me');
  });

  test('Public product search sends filters without leaking bearer', () async {
    server.body = {
      'data': [productJson],
    };
    final products = await api.getProducts(
      categoryId: 'category-1',
      search: 'maçã',
      brand: 'Marca',
    );
    expect(products.single.id, 'product-1');
    expect(products.single.price, 10.0);
    expect(products.single.description, 'Descrição real');
    expect(server.requests.single.queryParameters, {
      'categoryId': 'category-1',
      'search': 'maçã',
      'brand': 'Marca',
    });
    expect(
      server.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test('Private requests without a session never reach the server', () async {
    auth.logout();
    await expectLater(api.getCart(), throwsA(isA<ApiException>()));
    expect(server.requests, isEmpty);
  });

  test('Cart mutations use ids and accept authoritative totals', () async {
    server.body = cartBody();
    expect(await cart.addToCart(Products.fromJson(productJson)), isTrue);
    expect(server.requests.last.data, {
      'productId': 'product-1',
      'quantity': 1,
    });
    expect(cart.totalItems, 1);
    expect(cart.getTotalPrice(), 10);
    expect(cart.getProductQuantity('product-1'), 1);
    expect(cart.getProductQuantity('Mesmo nome'), 0);
    server.body = cartBody(quantity: 0);
    await cart.decrementFromCart('product-1');
    expect(server.requests.last.method, 'PATCH');
    expect(server.requests.last.path, '/cart/items/product-1');
    expect(server.requests.last.data, {'quantity': 0});
    expect(cart.cartItems, isEmpty);
  });

  test('Remove and clear use DELETE on the appropriate routes', () async {
    server.body = cartBody(quantity: 0);
    await cart.removeFromCart('product-1');
    expect(server.requests.last.method, 'DELETE');
    expect(server.requests.last.path, '/cart/items/product-1');
    await cart.clearCart();
    expect(server.requests.last.path, '/cart');
    expect(server.requests.last.method, 'DELETE');
  });

  test('Failed mutations preserve the last confirmed cart', () async {
    server.body = cartBody();
    await cart.loadCart();
    server.status = 500;
    server.body = {'message': 'Servidor indisponível'};
    expect(await cart.removeFromCart('product-1'), isFalse);
    expect(cart.totalItems, 1);
    expect(cart.error, 'Servidor indisponível');
    expect(cart.isLoading, isFalse);
  });

  test(
    'Switching users clears private data and rejects an old response',
    () async {
      server.body = cartBody();
      await cart.loadCart();
      final response = Completer<ResponseBody>();
      final started = Completer<void>();
      server.handler = (_) {
        started.complete();
        return response.future;
      };
      final pending = cart.loadCart();
      await started.future;
      auth.logout();
      await login('b');
      expect(cart.cartItems, isEmpty);
      response.complete(FakeServer.response(cartBody(quantity: 5)));
      expect(await pending, isFalse);
      expect(cart.cartItems, isEmpty);
      server.handler = null;
      server.body = cartBody(quantity: 0);
      await cart.loadCart();
      expect(server.requests.last.headers['Authorization'], 'Bearer token-b');
    },
  );

  test('401 expires the current session and clears its cart', () async {
    server.body = cartBody();
    await cart.loadCart();
    var expired = false;
    auth.onSessionExpired = () => expired = true;
    server.status = 401;
    server.body = {'message': 'Token inválido'};
    await cart.loadCart();
    expect(expired, isTrue);
    expect(auth.session, isNull);
    expect(cart.cartItems, isEmpty);
  });

  test('An old 401 cannot expire a new session', () async {
    final response = Completer<ResponseBody>();
    final started = Completer<void>();
    server.handler = (_) {
      started.complete();
      return response.future;
    };
    final pending = api.getOrders();
    await started.future;
    await login('b');
    final check = expectLater(pending, throwsA(isA<ApiException>()));
    response.complete(FakeServer.response({'message': 'Token inválido'}, 401));
    await check;
    expect(auth.session!.user.id, 'b');
  });

  test(
    'Checkout creates one order, blocks duplicates, and clears cart on success',
    () async {
      server.body = cartBody();
      await cart.loadCart();
      final response = Completer<ResponseBody>();
      final started = Completer<void>();
      server.handler = (_) {
        started.complete();
        return response.future;
      };
      final pending = cart.checkout();
      await started.future;
      expect(await cart.checkout(), isNull);
      expect(server.requests.last.method, 'POST');
      expect(server.requests.last.path, '/orders');
      response.complete(
        FakeServer.response({'id': 'order-1', 'status': 'PENDING'}, 201),
      );
      expect((await pending)!['id'], 'order-1');
      expect(cart.totalItems, 0);
      expect(cart.cartItems, isEmpty);
    },
  );

  test('Failed checkout keeps the cart available', () async {
    server.body = cartBody();
    await cart.loadCart();
    server.status = 400;
    server.body = {'message': 'Falha no pedido'};
    expect(await cart.checkout(), isNull);
    expect(cart.totalItems, 1);
    expect(cart.isLoading, isFalse);
  });

  test('Orders and order detail use authenticated endpoints', () async {
    server.body = {
      'data': [
        {'id': 'order-1'},
      ],
    };
    expect((await api.getOrders()).single['id'], 'order-1');
    server.body = {'id': 'order-1', 'items': []};
    expect((await api.getOrder('order-1'))['id'], 'order-1');
    expect(server.requests.last.path, '/orders/order-1');
    expect(server.requests.last.headers['Authorization'], 'Bearer token-a');
  });
}
