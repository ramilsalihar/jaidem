import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class FetchGoalsUseCase {
  final GoalRepository repository;

  const FetchGoalsUseCase(this.repository);

  Future<Either<String, List<GoalModel>>> call() async {
    return await repository.fetchGoals();
  }
}
