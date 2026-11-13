enum ApiFailureKind {
  http,
  timeout,
  connection,
  cancelled,
  certificate,
  unknown,
}

class ApiErrorDetail {
  const ApiErrorDetail({required this.field, required this.message});
  final String field;
  final String message;
}

/// Contrato Error do Swagger: code, message e details[{field, message}].
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.details = const [],
    this.kind = ApiFailureKind.http,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final List<ApiErrorDetail> details;
  final ApiFailureKind kind;

  @override
  String toString() => message;
}
