import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/opros/data/datasources/opros_remote_data_source.dart';
import 'package:jaidem/features/opros/data/datasources/opros_remote_data_source_impl.dart';
import 'package:jaidem/features/opros/data/repositories/opros_repository_impl.dart';
import 'package:jaidem/features/opros/domain/repositories/opros_repository.dart';
import 'package:jaidem/features/opros/domain/usecases/get_opros_questions_usecase.dart';
import 'package:jaidem/features/opros/domain/usecases/get_opros_status_usecase.dart';
import 'package:jaidem/features/opros/domain/usecases/submit_opros_answers_usecase.dart';
import 'package:jaidem/features/opros/presentation/cubit/opros_cubit.dart';

void oprosInjection() {
  // Data sources
  sl.registerSingleton<OprosRemoteDataSource>(
    OprosRemoteDataSourceImpl(dio: sl(), prefs: sl()),
  );

  // Repositories
  sl.registerLazySingleton<OprosRepository>(
    () => OprosRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetOprosStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetOprosQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitOprosAnswersUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => OprosCubit(
      getOprosStatusUseCase: sl(),
      getOprosQuestionsUseCase: sl(),
      submitOprosAnswersUseCase: sl(),
    ),
  );
}
