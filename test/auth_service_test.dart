import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_devs_do_zero/features/recover/controllers/recover_controller.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/services/session_storage.dart';

class MemorySessionStorage extends SessionStorage {
  SavedSession? saved;
  @override
  Future<SavedSession?> read() async => saved;
  @override
  Future<void> write(SavedSession session) async {
    saved = session;
  }

  @override
  Future<void> clear() async {
    saved = null;
  }
}

class StubAdapter implements HttpClientAdapter {
  late RequestOptions request;
  Object? body;
  int status = 200;
  bool timeout = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (timeout) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
    }
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late StubAdapter adapter;
  late AuthService service;
  late MemorySessionStorage storage;
  final authResponse = {
    'user': {'id': 'user-id', 'name': 'Ana', 'email': 'ana@example.com'},
    'tokens': {
      'accessToken': 'test-token',
      'tokenType': 'Bearer',
      'expiresIn': 604800,
    },
  };

  setUp(() {
    adapter = StubAdapter();
    final dio = Dio(BaseOptions(baseUrl: AuthService.baseUrl));
    dio.httpClientAdapter = adapter;
    storage = MemorySessionStorage();
    service = AuthService(dio: dio, storage: storage);
  });

  test(
    'Remembered login restores user from API with saved Bearer token',
    () async {
      adapter.body = authResponse;
      await service.login(
        email: 'ana@example.com',
        password: 'Senha@1',
        rememberMe: true,
      );
      expect(storage.saved?.token, 'test-token');
      final expiresAt = storage.saved!.expiresAt;
      final dio = Dio(BaseOptions(baseUrl: AuthService.baseUrl));
      dio.httpClientAdapter = adapter;
      final restarted = AuthService(dio: dio, storage: storage);
      adapter.body = {
        'id': 'user-id',
        'name': 'Nome atualizado',
        'email': 'ana@example.com',
      };
      await restarted.restoreSession();
      expect(adapter.request.method, 'GET');
      expect(adapter.request.path, '/users/me');
      expect(adapter.request.headers['Authorization'], 'Bearer test-token');
      expect(restarted.session?.user.nome, 'Nome atualizado');
      expect(restarted.session?.expiresAt, expiresAt);
      restarted.logout();
      await restarted.restoreSession();
      expect(storage.saved, isNull);
      expect(restarted.session, isNull);
    },
  );

  test('Login without remember-me removes a previous saved session', () async {
    storage.saved = SavedSession(
      'old',
      DateTime.now().add(const Duration(days: 1)),
    );
    adapter.body = authResponse;
    await service.login(email: 'ana@example.com', password: 'Senha@1');
    expect(storage.saved, isNull);
    expect(service.session, isNotNull);
  });

  test('Expired saved token is removed without restoring a session', () async {
    storage.saved = SavedSession(
      'expired',
      DateTime.now().subtract(const Duration(seconds: 1)),
    );
    await service.restoreSession();
    expect(storage.saved, isNull);
    expect(service.session, isNull);
  });

  for (final status in [401, 500]) {
    test('Restoration HTTP $status only clears invalid credentials', () async {
      storage.saved = SavedSession(
        'saved',
        DateTime.now().add(const Duration(days: 1)),
      );
      adapter.status = status;
      adapter.body = {'message': 'Erro'};
      await service.restoreSession();
      expect(service.session, isNull);
      expect(storage.saved == null, status == 401);
    });
  }

  test(
    'Restoration timeout preserves credentials for the next launch',
    () async {
      storage.saved = SavedSession(
        'saved',
        DateTime.now().add(const Duration(days: 1)),
      );
      adapter.timeout = true;
      await service.restoreSession();
      expect(service.session, isNull);
      expect(storage.saved?.token, 'saved');
    },
  );

  test('Login maps user and token, preserving the exact password', () async {
    adapter.body = authResponse;
    final session = await service.login(
      email: ' ana@example.com ',
      password: ' Senha@1 ',
    );
    expect(adapter.request.method, 'POST');
    expect(adapter.request.path, '/auth/login');
    expect(
      adapter.request.uri.toString(),
      'https://api-production-c0289.up.railway.app/api/v1/auth/login',
    );
    expect(adapter.request.data, {
      'email': 'ana@example.com',
      'password': ' Senha@1 ',
    });
    expect(session.user.nome, 'Ana');
    expect(session.accessToken, 'test-token');
    expect(session.expiresAt.isAfter(DateTime.now()), isTrue);
    expect(service.session, same(session));
    service.logout();
    expect(service.session, isNull);
  });

  test('Registration sends confirmation and accepted terms', () async {
    adapter.body = authResponse;
    adapter.status = 201;
    await service.register(
      name: ' Ana ',
      email: 'ana@example.com',
      password: 'Senha@1',
      confirmPassword: 'Senha@1',
      acceptedTerms: true,
    );
    expect(adapter.request.path, '/auth/register');
    expect(
      adapter.request.uri.toString(),
      'https://api-production-c0289.up.railway.app/api/v1/auth/register',
    );
    expect(adapter.request.data, {
      'name': 'Ana',
      'email': 'ana@example.com',
      'password': 'Senha@1',
      'confirmPassword': 'Senha@1',
      'acceptedTerms': true,
    });
  });

  test(
    'Recovery carries resetToken through the three steps and accepts 204',
    () async {
      final controller = RecoverController(authService: service);
      adapter.status = 202;
      adapter.body = {'message': 'Código enviado com sucesso'};
      await controller.sendCode(' ana@example.com ');
      expect(adapter.request.path, '/auth/password/forgot');
      expect(adapter.request.data, {'email': 'ana@example.com'});
      expect(controller.step, RecoveryStep.code);
      adapter.status = 200;
      adapter.body = {'resetToken': 'reset-token', 'expiresIn': 900};
      await controller.verifyCode('012345');
      expect(adapter.request.path, '/auth/password/verify-code');
      expect(adapter.request.data, {
        'email': 'ana@example.com',
        'code': '012345',
      });
      expect(controller.step, RecoveryStep.password);
      adapter.status = 204;
      adapter.body = null;
      await controller.resetPassword('Nova@123', 'Nova@123');
      expect(adapter.request.path, '/auth/password/reset');
      expect(adapter.request.data, {
        'resetToken': 'reset-token',
        'password': 'Nova@123',
        'confirmPassword': 'Nova@123',
      });
      expect(controller.step, RecoveryStep.email);
    },
  );

  for (final status in [400, 401, 409, 422, 429, 500]) {
    test('HTTP $status surfaces the API message', () async {
      adapter.status = status;
      adapter.body = {'code': 'TEST_ERROR', 'message': 'Mensagem da API'};
      await expectLater(
        service.login(email: 'ana@example.com', password: 'Senha@1'),
        throwsA(
          isA<AuthExeception>().having(
            (e) => e.message,
            'message',
            'Mensagem da API',
          ),
        ),
      );
      expect(service.session, isNull);
    });
  }

  test(
    'Invalid recovery code keeps the code step available for retry',
    () async {
      final controller = RecoverController(authService: service);
      adapter.status = 202;
      await controller.sendCode('ana@example.com');
      adapter.status = 400;
      adapter.body = {'message': 'Código inválido ou expirado'};
      await expectLater(
        controller.verifyCode('123456'),
        throwsA(isA<AuthExeception>()),
      );
      expect(controller.step, RecoveryStep.code);
    },
  );

  test('Timeout is translated to an authentication exception', () async {
    adapter.timeout = true;
    await expectLater(
      service.forgotPassword('ana@example.com'),
      throwsA(
        isA<AuthExeception>().having(
          (e) => e.message,
          'message',
          contains('demorou'),
        ),
      ),
    );
  });

  test('Malformed success response cannot create a session', () async {
    adapter.body = {'user': {}, 'tokens': {}};
    await expectLater(
      service.login(email: 'ana@example.com', password: 'Senha@1'),
      throwsA(isA<AuthExeception>()),
    );
    expect(service.session, isNull);
  });
}
