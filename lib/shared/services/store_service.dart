import 'package:dio/dio.dart';
import '../http/api_client.dart';
import '../http/dio_api_client.dart';
import '../exceptions/api_exception.dart';
export '../exceptions/api_exception.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';

class StoreService {
  StoreService(this.auth, {ApiClient? client, Dio? dio})
    : assert(client == null || dio == null),
      _client = client ?? DioApiClient(dio: dio);

  final AuthService auth;
  final ApiClient _client;
  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) async {
    final session = auth.session;
    if (authenticated &&
        (session == null || !session.expiresAt.isAfter(DateTime.now()))) {
      if (session != null) auth.expireSession(session);
      throw const ApiException('Sua sessão expirou. Faça login novamente.');
    }
    try {
      final response = await _client.request(
        path,
        data: data,
        query: query,

        method: method,
        headers: {
          if (authenticated) 'Authorization': 'Bearer ${session!.accessToken}',
        },
      );
      if (authenticated && !identical(session, auth.session)) {
        throw const ApiException('A sessão foi alterada.');
      }
      if (response is! Map<String, dynamic>) {
        throw const ApiException('Resposta inválida do servidor.');
      }
      return response;
    } on ApiException catch (error) {
      if (authenticated && error.statusCode == 401) {
        auth.expireSession(session!);
        throw ApiException(
          'Sua sessão expirou. Faça login novamente.',
          code: error.code,
          statusCode: error.statusCode,
          details: error.details,
          kind: error.kind,
        );
      }
      rethrow;
    }
  }

  Future<User> getMe() async => User.fromJson(await request('/users/me'));

  Future<List<Category>> getCategories() async {
    final body = await request('/categories', authenticated: false);
    return (body['data'] as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getBrands(String categoryId) async {
    final body = await request(
      '/categories/${Uri.encodeComponent(categoryId)}/brands',
      authenticated: false,
    );
    return List<String>.from(body['data'] as List);
  }

  Future<List<Products>> getProducts({
    String? categoryId,
    String? search,
    String? brand,
  }) async {
    final body = await request(
      '/products',
      authenticated: false,
      query: {
        'categoryId': ?categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (brand != null && brand.isNotEmpty) 'brand': brand,
      },
    );
    return (body['data'] as List)
        .map((e) => Products.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Products> getProduct(String id) async => Products.fromJson(
    await request('/products/${Uri.encodeComponent(id)}', authenticated: false),
  );

  Future<Map<String, dynamic>> getCart() => request('/cart');
  Future<Map<String, dynamic>> addItem(String id) => request(
    '/cart/items',
    method: 'POST',
    data: {'productId': id, 'quantity': 1},
  );
  Future<Map<String, dynamic>> updateItem(String id, int quantity) => request(
    '/cart/items/${Uri.encodeComponent(id)}',
    method: 'PATCH',
    data: {'quantity': quantity},
  );
  Future<Map<String, dynamic>> removeItem(String id) =>
      request('/cart/items/${Uri.encodeComponent(id)}', method: 'DELETE');
  Future<Map<String, dynamic>> clearCart() =>
      request('/cart', method: 'DELETE');
  Future<Map<String, dynamic>> createOrder() =>
      request('/orders', method: 'POST', data: <String, dynamic>{});
  Future<List<Map<String, dynamic>>> getOrders() async =>
      List<Map<String, dynamic>>.from(
        (await request('/orders'))['data'] as List,
      );
  Future<Map<String, dynamic>> getOrder(String id) =>
      request('/orders/${Uri.encodeComponent(id)}');
}
