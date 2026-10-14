import 'package:dio/dio.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class StoreService {
  StoreService(this.auth, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AuthService.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 15),
              contentType: Headers.jsonContentType,
            ),
          );

  final AuthService auth;
  final Dio _dio;

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
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {
            if (authenticated)
              'Authorization': 'Bearer ${session!.accessToken}',
          },
        ),
      );
      if (authenticated && !identical(session, auth.session)) {
        throw const ApiException('A sessão foi alterada.');
      }
      if (response.data is! Map<String, dynamic>) {
        throw const ApiException('Resposta inválida do servidor.');
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      if (authenticated && error.response?.statusCode == 401) {
        auth.expireSession(session!);
        throw const ApiException('Sua sessão expirou. Faça login novamente.');
      }
      final body = error.response?.data;
      if (body is Map && body['message'] is String) {
        throw ApiException(body['message'] as String);
      }
      throw const ApiException(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
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
