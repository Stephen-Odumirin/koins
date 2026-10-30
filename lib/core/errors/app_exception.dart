/// Why an operation failed, as a stable key. The UI maps it to localized
/// text.
enum AppExceptionCode {
  invalidCredentials,
  serverError,
  noInternet,
  timeout,
  badResponse,
}

class AppException implements Exception {
  const AppException(this.code, {this.statusCode});

  final AppExceptionCode code;

  /// The HTTP status for [AppExceptionCode.serverError].
  final int? statusCode;

  @override
  String toString() => 'AppException(${code.name}, status: $statusCode)';
}
