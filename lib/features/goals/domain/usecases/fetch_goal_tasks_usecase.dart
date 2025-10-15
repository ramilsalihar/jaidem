import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class FetchGoalTasksUseCase {
  final GoalRepository repository;

  const FetchGoalTasksUseCase(this.repository);

  Future<Either<String, ResponseModel<GoalTaskModel>>> call(String indicatorId) async {
    return await repository.getGoalTasks(indicatorId);
  }
}
