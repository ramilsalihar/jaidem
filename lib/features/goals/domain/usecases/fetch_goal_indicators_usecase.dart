import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class FetchGoalIndicatorsUseCase {
  final GoalRepository repository;

  const FetchGoalIndicatorsUseCase(this.repository);

  Future<Either<String, List<GoalIndicatorModel>>> call(String goalId) async {
    return await repository.fetchGoalIndicators(goalId);
  }
}
