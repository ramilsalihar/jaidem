import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'package:jaidem/features/profile/data/datasources/remote/profile_remote_data_source_impl.dart';
import 'package:jaidem/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:jaidem/features/profile/domain/repositories/profile_repository.dart';
import 'package:jaidem/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:jaidem/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';

void profileInjection() {
  // DataSource
  sl.registerSingleton<ProfileRemoteDataSource>(
    ProfileRemoteDataSourceImpl(dio: sl(), prefs: sl()),
  );

  // Repository
  sl.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerFactory(
    () => GetProfileUsecase(profileRepository: sl()),
  );

  sl.registerFactory(
    () => UpdateProfileUsecase(profileRepository: sl()),
  );

  // Cubits
  sl.registerFactory(
    () => ProfileCubit(
      getProfileUsecase: sl(),
      updateProfileUsecase: sl(),
    ),
  );
}
