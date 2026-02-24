import 'package:get_it/get_it.dart';
import 'package:jaidem/features/training/data/datasources/training_remote_datasource.dart';
import 'package:jaidem/features/training/data/datasources/training_remote_datasource_impl.dart';
import 'package:jaidem/features/training/domain/usecases/get_trainings_usecase.dart';
import 'package:jaidem/features/training/presentation/cubit/training_cubit.dart';

void initTrainingDependencies(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<TrainingRemoteDatasource>(
    () => TrainingRemoteDatasourceImpl(dio: sl()),
  );

  // Usecases
  sl.registerFactory(() => GetTrainingsUsecase(sl()));
  sl.registerFactory(() => GetTrainingByIdUsecase(sl()));
  sl.registerFactory(() => GetTrainingAnswersUsecase(sl()));
  sl.registerFactory(() => GetNPSQuestionsUsecase(sl()));
  sl.registerFactory(() => SubmitTrainingAnswerUsecase(sl()));

  // Cubit
  sl.registerFactory<TrainingCubit>(
    () => TrainingCubit(
      getTrainingsUsecase: sl(),
      getTrainingByIdUsecase: sl(),
      getTrainingAnswersUsecase: sl(),
      getNPSQuestionsUsecase: sl(),
      submitTrainingAnswerUsecase: sl(),
    ),
  );
}
