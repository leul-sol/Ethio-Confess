enum ErrorType {
  network,
  server,
  authentication,
  validation,
  notFound,
  unknown
}

class AppError {
  final String message;
  final ErrorType errorType;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    required this.errorType,
    this.originalError,
    this.stackTrace,
  });

  // Factory constructors for common error types
  factory AppError.network(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      message: message,
      errorType: ErrorType.network,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.server(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      message: message,
      errorType: ErrorType.server,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.authentication(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      message: message,
      errorType: ErrorType.authentication,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.validation(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      message: message,
      errorType: ErrorType.validation,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.notFound(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      message: message,
      errorType: ErrorType.notFound,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.unknown(String message, [dynamic originalError, StackTrace? stackTrace]) {
    return AppError(
      message: message,
      errorType: ErrorType.unknown,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => message;
} 