import 'dart:convert';
import 'dart:io';

import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:path_provider/path_provider.dart';

class MockAuth {
  static const String _fileName = 'mock_auth.json';

  static final Map<String, String> _credentials = {
    'vitor6890@gmail.com': '123456',
  };

  static final List<User> _users = [
    User(nome: 'Vitor', email: 'vitor6890@gmail.com'),
  ];

  static late final File _file;
  static bool _isInitialized = false;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _file = File('${directory.path}/$_fileName');

    if (_file.existsSync()) {
      _loadFromFile();
    } else {
      _saveToFile();
    }

    _isInitialized = true;
  }

  static void _loadFromFile() {
    if (!_file.existsSync()) {
      return;
    }

    try {
      final raw = _file.readAsStringSync();
      if (raw.trim().isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      final credentialsMap =
          decoded['credentials'] as Map<String, dynamic>? ?? {};
      final usersList = decoded['users'] as List<dynamic>? ?? [];

      _credentials.clear();
      credentialsMap.forEach((key, value) {
        _credentials[key.trim().toLowerCase()] = value.toString();
      });

      _users.clear();
      for (final user in usersList) {
        final map = user as Map<String, dynamic>;
        final nome = map['nome']?.toString() ?? '';
        final email = map['email']?.toString() ?? '';

        if (nome.isNotEmpty && email.isNotEmpty) {
          _users.add(User(nome: nome, email: email));
        }
      }
    } catch (_) {
      _credentials.clear();
      _credentials['vitor6890@gmail.com'] = '123456';
      _users
        ..clear()
        ..add(User(nome: 'Vitor', email: 'vitor6890@gmail.com'));
      _saveToFile();
    }
  }

  static void _saveToFile() {
    if (!_isInitialized && _file.path.isEmpty) {
      return;
    }

    final payload = {
      'credentials': _credentials,
      'users': _users
          .map((user) => {'nome': user.nome, 'email': user.email})
          .toList(),
    };

    _file.writeAsStringSync(jsonEncode(payload));
  }

  static void registerUser({
    required String nome,
    required String email,
    required String senha,
  }) {
    final normalizedEmail = email.trim();
    final normalizedNome = nome.trim();

    _credentials[normalizedEmail.toLowerCase()] = senha;

    final existingUserIndex = _users.indexWhere(
      (user) => user.email.toLowerCase() == normalizedEmail.toLowerCase(),
    );

    if (existingUserIndex >= 0) {
      _users[existingUserIndex] = User(
        nome: normalizedNome,
        email: normalizedEmail,
      );
    } else {
      _users.add(User(nome: normalizedNome, email: normalizedEmail));
    }

    _saveToFile();
  }

  static bool authenticate({required String email, required String senha}) {
    final normalizedEmail = email.trim().toLowerCase();
    final savedPassword = _credentials[normalizedEmail];

    return savedPassword != null && savedPassword == senha;
  }

  static User? getUser(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        return user;
      }
    }
    return null;
  }

  static List<User> get users => List.unmodifiable(_users);

  static void logoff() {}
}
