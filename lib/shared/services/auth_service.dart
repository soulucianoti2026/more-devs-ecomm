import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';

class AuthSession {
  final User user;
  final String accessToken;
  final DateTime expiresAt;

  AuthSession(this.user, this.accessToken, this.expiresAt);
}

class AuthService extends ChangeNotifier {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-production-c0289.up.railway.app/api/v1',
  );

  AuthService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              contentType: Headers.jsonContentType,
            ),
          );

  final Dio _dio;
  AuthSession? _session;
  AuthSession? get session => _session;
  VoidCallback? onSessionExpired;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _authenticate('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) {
    return _authenticate('/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'confirmPassword': confirmPassword,
      'acceptedTerms': acceptedTerms,
    });
  }

  Future<AuthSession> _authenticate(
    String path,
    Map<String, dynamic> data,
  ) async {
    final body = await _post(path, data);
    if (body is! Map<String, dynamic> ||
        body['user'] is! Map<String, dynamic> ||
        body['tokens'] is! Map<String, dynamic>) {
      throw AuthExeception('Resposta de autenticação inválida.');
    }
    final user = body['user'] as Map<String, dynamic>;
    final tokens = body['tokens'] as Map<String, dynamic>;
    final token = tokens['accessToken'];
    final expiresIn = tokens['expiresIn'];
    if (user['id'] is! String ||
        user['name'] is! String ||
        user['email'] is! String ||
        token is! String ||
        token.isEmpty ||
        expiresIn is! int ||
        expiresIn <= 0 ||
        tokens['tokenType'] != 'Bearer') {
      throw AuthExeception('Resposta de autenticação inválida.');
    }
    final result = AuthSession(
      User.fromJson(user),
      token,
      DateTime.now().add(Duration(seconds: expiresIn)),
    );
    _session = result;
    notifyListeners();
    return result;
  }

  Future<void> forgotPassword(String email) async {
    await _post('/auth/password/forgot', {'email': email.trim()});
  }

  Future<String> verifyCode({
    required String email,
    required String code,
  }) async {
    final body = await _post('/auth/password/verify-code', {
      'email': email.trim(),
      'code': code.trim(),
    });
    if (body is! Map<String, dynamic> ||
        body['resetToken'] is! String ||
        (body['resetToken'] as String).isEmpty) {
      throw AuthExeception('Resposta de recuperação inválida.');
    }
    return body['resetToken'] as String;
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    await _post('/auth/password/reset', {
      'resetToken': resetToken,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    logout();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }

  void expireSession(AuthSession expected) {
    if (!identical(_session, expected)) return;
    logout();
    onSessionExpired?.call();
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    try {
      return (await _dio.post<dynamic>(path, data: data)).data;
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map && body['message'] is String) {
        throw AuthExeception(body['message'] as String);
      }
      final message = switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'A conexão demorou demais. Tente novamente.',
        DioExceptionType.connectionError =>
          'Não foi possível conectar. Verifique sua conexão.',
        _ => 'Não foi possível concluir a solicitação. Tente novamente.',
      };
      throw AuthExeception(message);
    }
  }
}
