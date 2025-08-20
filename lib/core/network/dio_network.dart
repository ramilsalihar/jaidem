import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jaidem/core/app/app.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/auth/domain/repositories/auth_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioNetwork {
  static late Dio appAPI;
  static late Dio retryAPI;

  // Флаг и очередь для обработки обновления токена
  static bool isRefreshing = false;
  static List<Function> tokenRequestQueue = [];

  static void initDio() {
    appAPI = Dio(baseOptions(ApiConst.baseUrl));
    appAPI.interceptors.add(appQueuedInterceptorsWrapper());

    retryAPI = Dio(baseOptions(ApiConst.baseUrl));
    retryAPI.interceptors.add(interceptorsWrapper());
  }

  ///__________App__________///

  /// App Api Queued Interceptor
  static QueuedInterceptorsWrapper appQueuedInterceptorsWrapper() {
    return QueuedInterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
            // Retrieve token from SharedPreferences
            final prefs = sl<SharedPreferences>();
            String? token = prefs.getString(AppConstants.accessToken);

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            if (kDebugMode) {
              print("Request Headers after adding access token:");
              print(json.encode(options.headers));
            }

            return handler.next(options);
          },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final prefs = sl<SharedPreferences>();
        final token = prefs.getString(AppConstants.accessToken);
        final isExpired = token != null && JwtDecoder.isExpired(token);

        if (error.response?.statusCode == 401 && isExpired) {
          if (!isRefreshing) {
            isRefreshing = true;
            try {
              final refreshResult = await sl<AuthRepository>()
                  .getAccessToken();

              refreshResult.fold(
                (errorMessage) {
                  // Token refresh failed
                  log("Token refresh failed: $errorMessage");
                  isRefreshing = false;

                  // Sign out and redirect to splash
                  sl<AuthRepository>().signOut().then((signOutResult) {
                    signOutResult.fold(
                      (signOutError) => log("Sign out error: $signOutError"),
                      (_) => log("Successfully signed out"),
                    );
                  });

                  appRouter.pushAndPopUntil(
                    const SplashRoute(),
                    predicate: (route) => false,
                  );
                  handler.reject(error);
                },
                (_) {
                  // Token refresh successful
                  final newAccessToken = prefs.getString(
                    AppConstants.accessToken,
                  );

                  // Update requests waiting for a new token
                  for (var callback in tokenRequestQueue) {
                    callback();
                  }
                  tokenRequestQueue.clear();
                  isRefreshing = false;

                  // Retry the request with the new token
                  if (newAccessToken != null) {
                    error.requestOptions.headers['Authorization'] =
                        'Bearer $newAccessToken';
                    sl<Dio>()
                        .fetch(error.requestOptions)
                        .then((newRequest) {
                          handler.resolve(newRequest);
                        })
                        .catchError((e) {
                          log("Error retrying request: $e");
                          handler.reject(error);
                        });
                  } else {
                    handler.reject(error);
                  }
                },
              );
            } catch (e) {
              log("Exception during token refresh: $e");
              isRefreshing = false;

              sl<AuthRepository>().signOut().then((signOutResult) {
                signOutResult.fold(
                  (signOutError) => log("Sign out error: $signOutError"),
                  (_) => log("Successfully signed out"),
                );
              });

              appRouter.pushAndPopUntil(
                const SplashRoute(),
                predicate: (route) => false,
              );
              return handler.reject(error);
            }
          } else {
            return await _addToQueue(error.requestOptions, handler);
          }
        }
        return handler.next(error);
      },
    );
  }

  // Функция для добавления запросов в очередь во время обновления токена
  static Future<void> _addToQueue(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final completer = Completer<void>();
    tokenRequestQueue.add(() async {
      final prefs = sl<SharedPreferences>();
      final newAccessToken = prefs.getString(AppConstants.accessToken);

      if (newAccessToken != null) {
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        sl<Dio>()
            .fetch(requestOptions)
            .then((newRequest) {
              handler.resolve(newRequest);
              completer.complete();
            })
            .catchError((e) {
              log("Error fetching queued request: $e");
              handler.reject(
                DioException(requestOptions: requestOptions, error: e),
              );
              completer.complete();
            });
      } else {
        handler.reject(
          DioException(
            requestOptions: requestOptions,
            error: "No access token available",
          ),
        );
        completer.complete();
      }
    });
    return completer.future;
  }

  /// App interceptor
  static InterceptorsWrapper interceptorsWrapper() {
    return InterceptorsWrapper(
      onRequest: (RequestOptions options, r) async {
        final prefs = sl<SharedPreferences>();
        final token = prefs.getString(AppConstants.accessToken);

        log("Token: $token", name: 'AccessToken');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print("Request Headers after adding custom headers:");
          print(json.encode(options.headers));
        }

        return r.next(options);
      },
      onResponse: (response, handler) async {
        if ("${(response.data["code"] ?? "0")}" != "0") {
          return handler.resolve(response);
        } else {
          return handler.next(response);
        }
      },
      onError: (error, handler) {
        try {
          return handler.next(error);
        } catch (e) {
          return handler.reject(error);
        }
      },
    );
  }

  static BaseOptions baseOptions(String url) {
    return BaseOptions(
      baseUrl: url,
      validateStatus: (s) {
        return s! < 300;
      },
      responseType: ResponseType.json,
    );
  }
}