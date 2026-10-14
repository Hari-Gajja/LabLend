class AppFailure implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final List<dynamic>? errors;

  AppFailure({
    required this.message,
    this.code = 'UNKNOWN_ERROR',
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'AppFailure($code: $message)';
}

class NetworkFailure extends AppFailure {
  NetworkFailure([String message = 'Unable to connect to the server. Please check your network.'])
      : super(message: message, code: 'NETWORK_ERROR');
}

class UnauthorizedFailure extends AppFailure {
  UnauthorizedFailure([String message = 'Session expired. Please log in again.'])
      : super(message: message, code: 'UNAUTHORIZED', statusCode: 401);
}

class ValidationFailure extends AppFailure {
  ValidationFailure(String message, {super.errors})
      : super(message: message, code: 'VALIDATION_ERROR', statusCode: 400);
}

class ConflictFailure extends AppFailure {
  ConflictFailure(String message)
      : super(message: message, code: 'CONFLICT_ERROR', statusCode: 409);
}
