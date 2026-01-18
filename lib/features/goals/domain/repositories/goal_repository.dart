import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';

abstract class GoalRepository {
  // Goals
  Future<Either<String, List<GoalModel>>> fetchGoals();
  Future<Either<String, GoalModel>> createGoal(GoalModel goal);
  Future<Either<String, GoalModel>> updateGoal(GoalModel goal);

  // Indicators
  Future<Either<String, List<GoalIndicatorModel>>> fetchGoalIndicators(
    String goalId,
  );
  Future<Either<String, GoalIndicatorModel>> createGoalIndicator(
    GoalIndicatorModel indicator,
  );

  Future<Either<String, GoalIndicatorModel>> updateGoalIndicator(
    GoalIndicatorModel indicator,
  );

  Future<Either<String, void>> deleteGoalIndicator(
    String indicatorId,
  );

  Future<Either<String, GoalIndicatorModel>> fetchGoalIndicatorById(
    String indicatorId,
  );

  // Tasks
  Future<Either<String, GoalTaskModel>> createGoalTask(
    GoalTaskModel task,
  );

  Future<Either<String, ResponseModel<GoalTaskModel>>> getGoalTasks(
    String indicatorId,
  );

  Future<Either<String, GoalTaskModel>> updateGoalTask(
    GoalTaskModel task,
  );
}
