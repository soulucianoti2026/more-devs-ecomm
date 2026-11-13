import 'package:dio/dio.dart';
import 'session_storage.dart';
import '../http/api_client.dart';
import '../http/dio_api_client.dart';
import '../http/api_config.dart';
import '../exceptions/api_exception.dart';
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
  static const baseUrl = ApiConfig.baseUrl;

  AuthService({ApiClient? client, Dio? dio, SessionStorage? storage})
    : assert(client == null || dio == null),
      _storage = storage ?? SessionStorage(),
      _client = client ?? DioApiClient(dio: dio);

  final ApiClient _client;
  final SessionStorage _storage;
  Future<void> _storageTask = Future<void>.value();
  int _sessionVersion = 0;

  // Serialize writes so a previous logout cannot erase a newer login.
  Future<void> _updateStorage(Future<void> Function() action) {
    return _storageTask = _storageTask.then((_) => action()).catchError((
      Object _,
    ) {
      // Storage failures must not prevent API authentication or local logout.
    });
  }

  Future<void> restoreSession() async {
    final expected = _sessionVersion;
    try {
      await _storageTask;
      final saved = await _storage.read();
      if (expected != _sessionVersion) return;
      if (saved == null) return;
      if (!saved.expiresAt.isAfter(DateTime.now())) {
        await _updateStorage(_storage.clear);
        return;
      }
      final body = await _client.get(
        '/users/me',
        headers: {'Authorization': 'Bearer ${saved.token}'},
      );
      if (expected != _sessionVersion) return;
      final user = User.fromJson(body as Map<String, dynamic>);
      _session = AuthSession(user, saved.token, saved.expiresAt);
      _sessionVersion++;
      notifyListeners();
    } on ApiException catch (error) {
      if (error.statusCode == 401 && expected == _sessionVersion) {
        await _updateStorage(_storage.clear);
      }
      // Keep the saved token on temporary network/server failures.
    } catch (_) {
      // Startup remains available if local storage cannot be read.
    }
  }

  AuthSession? _session;
  AuthSession? get session => _session;
  VoidCallback? onSessionExpired;

  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return _authenticate('/auth/login', {
      'email': email.trim(),
      'password': password,
    }, rememberMe: rememberMe);
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
    Map<String, dynamic> data, {
    bool rememberMe = false,
  }) async {
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
    _sessionVersion++;
    notifyListeners();
    await _updateStorage(
      () => rememberMe
          ? _storage.write(SavedSession(token, result.expiresAt))
          : _storage.clear(),
    );
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
    _sessionVersion++;
    _session = null;
    _updateStorage(_storage.clear);
    notifyListeners();
  }

  void expireSession(AuthSession expected) {
    if (!identical(_session, expected)) return;
    logout();
    onSessionExpired?.call();
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    try {
      return await _client.post(path, data: data);
    } on ApiException catch (error) {
      throw AuthExeception.fromApi(error);
    }
  }
}
