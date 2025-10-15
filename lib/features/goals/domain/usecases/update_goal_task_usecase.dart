import 'package:dartz/dartz.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class UpdateGoalTaskUsecase {
  final GoalRepository repository;

  UpdateGoalTaskUsecase(this.repository);

  Future<Either<String, GoalTaskModel>> call(GoalTaskModel task) {
    return repository.updateGoalTask(task);
  }
}
