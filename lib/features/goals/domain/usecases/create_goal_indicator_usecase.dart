import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class CreateGoalIndicatorUseCase {
  final GoalRepository repository;

  const CreateGoalIndicatorUseCase(this.repository);

  Future<Either<String, GoalIndicatorModel>> call(GoalIndicatorModel indicator) async {
    return await repository.createGoalIndicator(indicator);
  }
}
