import 'package:dio/dio.dart';

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

class ExceptionHandler {
  static String handleDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timeout';
      case DioExceptionType.badResponse:
        switch (dioException.response?.statusCode) {
          case 400:
            return 'Bad request';
          case 401:
            return 'Unauthorized';
          case 403:
            return 'Forbidden';
          case 404:
            return 'Not found';
          case 500:
            return 'Internal server error';
          default:
            return 'Server error occurred';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.unknown:
      default:
        return 'Network error occurred';
    }
  }

  static String handleGeneralException(Object exception) {
    if (exception is AppExceptions) {
      return exception.message;
    }
    return 'An unexpected error occurred';
  }
}
