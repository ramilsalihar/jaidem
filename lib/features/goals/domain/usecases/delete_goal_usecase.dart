import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class DeleteGoalUseCase {
  final GoalRepository repository;

  DeleteGoalUseCase(this.repository);

  Future<Either<String, void>> call(String goalId) {
    return repository.deleteGoal(goalId);
  }
}
