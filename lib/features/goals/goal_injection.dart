import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source_impl.dart';
import 'package:jaidem/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goals_usecase.dart';
import 'package:jaidem/features/goals/presentation/cubit/goals_cubit.dart';

void goalInjection() {
  // Data sources
  sl.registerSingleton<GoalRemoteDataSource>(
    GoalRemoteDataSourceImpl(
      dio: sl(),
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

  // Cubits
  sl.registerFactory(
    () => GoalsCubit(
      fetchGoalsUseCase: sl(),
      createGoalUseCase: sl(),
    ),
  );
}
