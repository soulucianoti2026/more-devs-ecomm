import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_devs_do_zero/shared/exceptions/api_exception.dart';
import 'package:more_devs_do_zero/shared/http/dio_api_client.dart';
import 'auth_service_test.dart' show StubAdapter;

void main() {
  late StubAdapter adapter;
  late DioApiClient client;
  setUp(() {
    adapter = StubAdapter();
    client = DioApiClient(
      dio: Dio(BaseOptions(baseUrl: 'https://example.com/api/v1'))
        ..httpClientAdapter = adapter,
    );
  });

  test('All HTTP verbs preserve query, body and per-request headers', () async {
    adapter.body = {'ok': true};
    final calls = {
      'GET': () =>
          client.get('/items', query: {'page': 2}, headers: {'X-Test': 'yes'}),
      'POST': () => client.post('/items', data: {'quantity': 2}),
      'PUT': () => client.put('/items', data: {'quantity': 2}),
      'PATCH': () => client.patch('/items', data: {'quantity': 2}),
      'DELETE': () => client.delete('/items', data: {'quantity': 2}),
    };
    for (final call in calls.entries) {
      expect(await call.value(), {'ok': true});
      expect(adapter.request.method, call.key);
      expect(adapter.request.uri.path, '/api/v1/items');
      if (call.key == 'GET') {
        expect(adapter.request.queryParameters, {'page': 2});
        expect(adapter.request.headers['X-Test'], 'yes');
      } else {
        expect(adapter.request.data, {'quantity': 2});
        expect(adapter.request.headers.containsKey('X-Test'), isFalse);
      }
    }
  });

  test(
    'Swagger error preserves stable code and field validation details',
    () async {
      adapter.status = 422;
      adapter.body = {
        'code': 'VALIDATION_ERROR',
        'message': 'Dados inválidos',
        'details': [
          {'field': 'email', 'message': 'E-mail inválido'},
        ],
      };
      await expectLater(
        client.post('/items'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'VALIDATION_ERROR')
              .having((e) => e.statusCode, 'status', 422)
              .having((e) => e.message, 'message', 'Dados inválidos')
              .having((e) => e.details.single.field, 'field', 'email')
              .having(
                (e) => e.details.single.message,
                'field message',
                'E-mail inválido',
              ),
        ),
      );
    },
  );

  test('Malformed error details do not hide the API message', () async {
    adapter.status = 400;
    adapter.body = {
      'message': 'Erro da API',
      'code': 123,
      'details': [
        null,
        {'field': 1},
        {'field': 'name', 'message': 'Obrigatório'},
      ],
    };
    await expectLater(
      client.get('/items'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', isNull)
            .having((e) => e.details.length, 'valid details', 1),
      ),
    );
  });

  test('Non-JSON HTTP error receives a safe status fallback', () async {
    adapter.status = 503;
    adapter.body = '<html>Proxy error</html>';
    await expectLater(
      client.get('/items'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 503)
            .having(
              (e) => e.message,
              'message',
              contains('Servidor indisponível'),
            ),
      ),
    );
  });

  test('204 accepts an empty body', () async {
    adapter.status = 204;
    await client.delete('/items');
  });

  for (final type in DioExceptionType.values) {
    test('Transport failure $type never leaks DioException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(DioException(requestOptions: options, type: type));
          },
        ),
      );
      await expectLater(
        DioApiClient(dio: dio).get('/items'),
        throwsA(isA<ApiException>()),
      );
    });
  }
}
