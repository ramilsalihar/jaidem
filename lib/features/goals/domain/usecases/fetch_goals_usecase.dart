import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/domain/repositories/goal_repository.dart';

class FetchGoalsUseCase {
  final GoalRepository repository;

  const FetchGoalsUseCase(this.repository);

  Future<Either<String, ResponseModel<GoalModel>>> call({int page = 1, String? status}) async {
    return await repository.fetchGoals(page: page, status: status);
  }
}
