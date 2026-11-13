import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SavedSession {
  const SavedSession(this.token, this.expiresAt);
  final String token;
  final DateTime expiresAt;
}

class SessionStorage {
  static const _key = 'auth_session';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<SavedSession?> read() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    try {
      final data = jsonDecode(value) as Map<String, dynamic>;
      final token = data['token'] as String;
      if (token.isEmpty) throw const FormatException();
      return SavedSession(token, DateTime.parse(data['expiresAt'] as String));
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(SavedSession session) => _storage.write(
    key: _key,
    value: jsonEncode({
      'token': session.token,
      'expiresAt': session.expiresAt.toUtc().toIso8601String(),
    }),
  );

  Future<void> clear() => _storage.delete(key: _key);
}
