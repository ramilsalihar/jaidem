import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
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

  // @override
  // Future<Either<String, void>> deleteGoal(String goalId) {
  //   return remoteDataSource.deleteGoal(goalId).then((result) {
  //     return result.fold(
  //       (failure) => Left(failure),
  //       (responseModel) {
  //         if (responseModel.results.isNotEmpty) {
  //           return Right(responseModel.results.first);
  //         } else {
  //           return const Left('No goal returned from server');
  //         }
  //       },
  //     );
  //   });
  // }

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
}
