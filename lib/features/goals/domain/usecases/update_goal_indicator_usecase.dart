import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class UpdateGoalIndicatorUseCase {
  final GoalRepository repository;

  UpdateGoalIndicatorUseCase(this.repository);

  Future<Either<String, GoalIndicatorModel>> call(GoalIndicatorModel indicator) {
    return repository.updateGoalIndicator(indicator);
  }
}
