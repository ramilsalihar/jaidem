import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class FetchGoalIndicatorByIdUseCase {
  final GoalRepository repository;

  FetchGoalIndicatorByIdUseCase(this.repository);

  Future<Either<String, GoalIndicatorModel>> call(String indicatorId) {
    return repository.fetchGoalIndicatorById(indicatorId);
  }
}
