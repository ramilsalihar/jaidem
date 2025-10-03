import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class CreateGoalUseCase {
  final GoalRepository repository;

  const CreateGoalUseCase(this.repository);

  Future<Either<String, GoalModel>> call(GoalModel goal) async {
    return await repository.createGoal(goal);
  }
}
