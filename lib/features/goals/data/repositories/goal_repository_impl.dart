import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;

  GoalRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<String, GoalModel>> createGoal(GoalModel goal) {
    return remoteDataSource.createGoal(goal).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, List<GoalModel>>> fetchGoals() {
    return remoteDataSource.getGoals().then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          if (responseModel.results.isNotEmpty) {
            return Right(responseModel.results);
          } else {
            return const Left('No goals returned from server');
          }
        },
      );
    });
  }

  @override
  Future<Either<String, GoalModel>> updateGoal(GoalModel goal) {
    return remoteDataSource.updateGoal(goal).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, GoalIndicatorModel>> createGoalIndicator(
    GoalIndicatorModel indicator,
  ) {
    return remoteDataSource.createGoalIndicator(indicator).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, List<GoalIndicatorModel>>> fetchGoalIndicators(
    String goalId,
  ) async {
    return await remoteDataSource.getGoalIndicators(goalId).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          // Return empty list instead of error when no indicators found
          return Right(responseModel.results);
        },
      );
    });
  }

  @override
  Future<Either<String, GoalTaskModel>> createGoalTask(GoalTaskModel task) {
    return remoteDataSource.createGoalTask(task).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, ResponseModel<GoalTaskModel>>> getGoalTasks(
      String indicatorId) {
    return remoteDataSource.getGoalTasks(indicatorId).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, GoalTaskModel>> updateGoalTask(GoalTaskModel task) {
    return remoteDataSource.updateGoalTask(task).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, void>> deleteGoalIndicator(String indicatorId) {
    return remoteDataSource.deleteGoalIndicator(indicatorId).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, GoalIndicatorModel>> fetchGoalIndicatorById(
      String indicatorId) {
    return remoteDataSource.fetchGoalIndicatorById(indicatorId).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }

  @override
  Future<Either<String, GoalIndicatorModel>> updateGoalIndicator(
      GoalIndicatorModel indicator) {
    return remoteDataSource.updateGoalIndicator(indicator).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) {
          return Right(responseModel);
        },
      );
    });
  }
}
