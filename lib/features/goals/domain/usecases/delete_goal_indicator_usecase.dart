import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class DeleteGoalIndicatorUseCase {
  final GoalRepository repository;

  DeleteGoalIndicatorUseCase(this.repository);

  Future<Either<String, void>> call(String indicatorId) {
    return repository.deleteGoalIndicator(indicatorId);
  }
}
