import 'package:dio/dio.dart';
import '../exceptions/api_exception.dart';
import 'api_client.dart';
import 'api_config.dart';

class DioApiClient implements ApiClient {
  DioApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              contentType: Headers.jsonContentType,
            ),
          );

  final Dio _dio;

  @override
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return (await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method, headers: headers),
      )).data;
    } on DioException catch (error) {
      throw _translate(error);
    }
  }

  ApiException _translate(DioException error) {
    final kind = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.receiveTimeout => ApiFailureKind.timeout,
      DioExceptionType.connectionError => ApiFailureKind.connection,
      DioExceptionType.cancel => ApiFailureKind.cancelled,
      DioExceptionType.badCertificate => ApiFailureKind.certificate,
      DioExceptionType.badResponse => ApiFailureKind.http,
      DioExceptionType.unknown => ApiFailureKind.unknown,
    };
    final status = error.response?.statusCode;
    final fallback = switch (kind) {
      ApiFailureKind.timeout => 'A conexão demorou demais. Tente novamente.',
      ApiFailureKind.connection =>
        'Não foi possível conectar. Verifique sua conexão.',
      ApiFailureKind.cancelled => 'Solicitação cancelada.',
      ApiFailureKind.certificate =>
        'Não foi possível estabelecer uma conexão segura.',
      _ => switch (status ?? 0) {
        400 || 422 => 'Dados inválidos. Verifique os campos informados.',
        401 => 'Não autorizado. Faça login novamente.',
        403 => 'Você não tem permissão para realizar esta ação.',
        404 => 'Recurso não encontrado.',
        409 => 'A solicitação conflita com os dados atuais.',
        429 => 'Muitas solicitações. Tente novamente mais tarde.',
        >= 500 => 'Servidor indisponível. Tente novamente mais tarde.',
        _ => 'Não foi possível concluir a solicitação. Tente novamente.',
      },
    };
    final body = error.response?.data;
    final message = body is Map ? body['message'] : null;
    final code = body is Map ? body['code'] : null;
    final details = body is Map ? body['details'] : null;
    return ApiException(
      message is String && message.trim().isNotEmpty ? message : fallback,
      code: code is String ? code : null,
      statusCode: status,
      kind: kind,
      details: List.unmodifiable([
        if (details is List)
          for (final detail in details)
            if (detail is Map &&
                detail['field'] is String &&
                detail['message'] is String)
              ApiErrorDetail(
                field: detail['field'] as String,
                message: detail['message'] as String,
              ),
      ]),
    );
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) => request(path, method: 'GET', query: query, headers: headers);
  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) =>
      request(path, method: 'POST', data: data, query: query, headers: headers);
  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) =>
      request(path, method: 'PUT', data: data, query: query, headers: headers);
  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) => request(
    path,
    method: 'PATCH',
    data: data,
    query: query,
    headers: headers,
  );
  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) => request(
    path,
    method: 'DELETE',
    data: data,
    query: query,
    headers: headers,
  );
}
