import 'api_exception.dart';

// Nome mantido para compatibilidade com os consumidores existentes.
class AuthExeception extends ApiException {
  const AuthExeception(
    super.message, {
    super.code,
    super.statusCode,
    super.details,
    super.kind,
  });

  AuthExeception.fromApi(ApiException error)
    : super(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
        details: error.details,
        kind: error.kind,
      );
}
