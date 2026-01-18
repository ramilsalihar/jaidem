import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source_impl.dart';
import 'package:jaidem/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_indicator_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_task_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/delete_goal_indicator_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goals_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_indicators_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_indicator_by_id_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_tasks_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/update_goal_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/update_goal_indicator_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/update_goal_task_usecase.dart';
import 'package:jaidem/features/goals/presentation/cubit/goals/goals_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/indicators/indicators_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/tasks/tasks_cubit.dart';

void goalInjection() {
  // Data sources
  sl.registerSingleton<GoalRemoteDataSource>(
    GoalRemoteDataSourceImpl(
      dio: sl(),
      prefs: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => FetchGoalsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => CreateGoalUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => FetchGoalIndicatorsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => CreateGoalIndicatorUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => FetchGoalTasksUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => CreateGoalTaskUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => UpdateGoalTaskUsecase(sl()),
  );
  sl.registerLazySingleton(
    () => DeleteGoalIndicatorUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => FetchGoalIndicatorByIdUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => UpdateGoalIndicatorUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => UpdateGoalUseCase(sl()),
  );

  // Cubits
  sl.registerFactory(
    () => GoalsCubit(
      fetchGoalsUseCase: sl(),
      createGoalUseCase: sl(),
      updateGoalUseCase: sl(),
    ),
  );
  
  sl.registerFactory(
    () => IndicatorsCubit(
      fetchGoalIndicatorsUseCase: sl(),
      createGoalIndicatorUseCase: sl(),
      updateGoalIndicatorUseCase: sl(),
      deleteGoalIndicatorUseCase: sl(),
      fetchGoalIndicatorByIdUseCase: sl(),
    ),
  );
  
  sl.registerFactory(
    () => TasksCubit(
      fetchGoalTasksUseCase: sl(),
      createGoalTaskUseCase: sl(),
      updateGoalTaskUseCase: sl(),
    ),
  );
}
