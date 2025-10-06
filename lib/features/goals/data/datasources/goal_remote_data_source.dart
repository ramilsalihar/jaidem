import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<Either<String, ResponseModel<GoalModel>>> getGoals();

  Future<Either<String, GoalModel>> createGoal(
    GoalModel goal,
  );

  Future<Either<String, ResponseModel<GoalIndicatorModel>>> getGoalIndicators(
    String goalId,
  );

  Future<Either<String, GoalIndicatorModel>> createGoalIndicator(
    GoalIndicatorModel indicator,
  );
}
