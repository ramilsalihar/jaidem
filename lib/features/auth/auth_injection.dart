import 'package:dio/dio.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/network/network_info.dart';
import 'package:jaidem/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:jaidem/features/auth/data/datasources/local/auth_local_data_source_impl.dart';
import 'package:jaidem/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:jaidem/features/auth/data/datasources/remote/auth_remote_data_source_impl.dart';
import 'package:jaidem/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jaidem/features/auth/domain/repositories/auth_repository.dart';
import 'package:jaidem/features/auth/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:jaidem/features/auth/domain/usecases/login_usecase.dart';
import 'package:jaidem/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jaidem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void authInjection() {
  // Data Sources
  sl.registerSingleton<AuthLocalDataSource>(
    AuthLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  sl.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Repositories
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      localDataSource: sl<AuthLocalDataSource>(),
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerFactory(() => LoginUsecase(sl()));
  sl.registerFactory(() => IsUserLoggedInUsecase(sl()));
  sl.registerFactory(() => SignOutUsecase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthCubit(
      loginUsecase: sl<LoginUsecase>(),
      signOutUsecase: sl<SignOutUsecase>(),
      isUserLoggedInUsecase: sl<IsUserLoggedInUsecase>(),
    ),
  );
}
