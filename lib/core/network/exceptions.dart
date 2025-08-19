class AppExceptions implements Exception {
  final String message;
  final int? statusCode;

  const AppExceptions({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppExceptions {
  const NetworkException({
    super.message = 'Network error occurred',
    super.statusCode,
  });
}

class ServerException extends AppExceptions {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode,
  });
}

class CacheException extends AppExceptions {
  const CacheException({
    super.message = 'Cache error occurred',
  });
}

class ValidationException extends AppExceptions {
  const ValidationException({
    super.message = 'Validation error occurred',
  });
}

class AuthException extends AppExceptions {
  const AuthException({
    super.message = 'Authentication error occurred',
    super.statusCode,
  });
}

class TimeoutException extends AppExceptions {
  const TimeoutException({
    super.message = 'Request timeout',
  });
}

class NoInternetException extends AppExceptions {
  const NoInternetException({
    super.message = 'No internet connection',
  });
}
