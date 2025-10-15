import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class CreateGoalTaskUseCase {
  final GoalRepository repository;

  const CreateGoalTaskUseCase(this.repository);

  Future<Either<String, GoalTaskModel>> call(GoalTaskModel task) async {
    return await repository.createGoalTask(task);
  }
}
