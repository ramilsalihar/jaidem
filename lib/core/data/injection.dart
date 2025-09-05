import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/network/network_info.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/style/app_theme.dart';
import 'package:jaidem/features/auth/auth_injection.dart';
import 'package:jaidem/features/forum/forum_injection.dart';
import 'package:jaidem/features/goals/goal_injection.dart';
import 'package:jaidem/features/menu/manu_injection.dart';
import 'package:jaidem/features/profile/profile_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  sl.registerLazySingleton<ThemeData>(
    () => AppTheme.lightTheme,
  );

  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  await setupServices();

  authInjection();

  menuInjection();

  profileInjection();

  goalInjection();

  forumInjection();
}

Future<void> setupServices() async {
  sl.registerSingletonAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );

  await sl.isReady<SharedPreferences>();

// Clear SharedPreferences
  // await sl<SharedPreferences>().clear();

  // final appInfo = await AppInfo.init();
  // sl.registerSingleton<AppInfo>(appInfo);

  // sl.registerLazySingleton<FirebaseFirestore>(
  //   () => FirebaseFirestore.instance,
  // );

  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  await dioInjection();
}

Future<void> dioInjection() async {
  DioNetwork.initDio();
  sl.registerLazySingleton(() => DioNetwork.appAPI);
  sl<Dio>().interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
}
