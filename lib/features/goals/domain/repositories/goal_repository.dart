import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';

abstract class GoalRepository {
  Future<Either<String, List<GoalModel>>> fetchGoals();
  Future<Either<String, GoalModel>> createGoal(GoalModel goal);
  // Future<Either<String, GoalModel>> updateGoal(GoalModel goal);
  // Future<Either<String, void>> deleteGoal(String goalId);
}
