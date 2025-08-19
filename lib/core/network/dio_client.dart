import 'package:dio/dio.dart';
import '../utils/constants/app_constants.dart';
import 'network_info.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));

    // Add network connectivity interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final networkInfo = NetworkInfo();
        final isConnected = await networkInfo.isConnected;
        
        if (!isConnected) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'No internet connection',
            ),
          );
          return;
        }
        
        handler.next(options);
      },
    ));

    return dio;
  }

  static void addAuthInterceptor(String token) {
    _dio?.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
  }

  static void removeAuthInterceptor() {
    _dio?.interceptors.removeWhere(
      (interceptor) => interceptor is InterceptorsWrapper,
    );
  }
}
