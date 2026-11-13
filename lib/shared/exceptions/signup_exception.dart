import 'auth_exeception.dart';
import 'api_exception.dart';

enum SignupExceptionType {
  emailAlreadyInUse,
  invalidForm,
  termsNotAccepted,
  network,
  unknown,
}

/// Preserves the user-facing API error while exposing a safe analytics type.
class SignupException extends AuthExeception {
  SignupException.fromAuth(AuthExeception error)
    : type = _typeFor(error),
      super(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
        details: error.details,
        kind: error.kind,
      );

  final SignupExceptionType type;

  static SignupExceptionType _typeFor(AuthExeception error) {
    if (error.details.any((detail) => detail.field == 'acceptedTerms')) {
      return SignupExceptionType.termsNotAccepted;
    }
    if (error.statusCode == 409) return SignupExceptionType.emailAlreadyInUse;
    if (error.statusCode == 400 || error.statusCode == 422) {
      return SignupExceptionType.invalidForm;
    }
    if (error.kind == ApiFailureKind.connection ||
        error.kind == ApiFailureKind.timeout) {
      return SignupExceptionType.network;
    }
    return SignupExceptionType.unknown;
  }
}
