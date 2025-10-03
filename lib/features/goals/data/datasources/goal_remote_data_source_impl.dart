import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final Dio dio;

  const GoalRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<String, ResponseModel<GoalModel>>> getGoals() async {
    try {
      final response = await dio.get(ApiConst.goals);

      if ([200, 201].contains(response.statusCode)) {
        final responseModel = ResponseModel<GoalModel>.fromJson(
          response.data,
          (json) => GoalModel.fromJson(json),
        );
        return Right(responseModel);
      } else {
        return const Left('Failed to fetch goals');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, ResponseModel<GoalModel>>> createGoal(
      GoalModel goal) async {
    try {
      final response = await dio.post(
        ApiConst.goals,
        data: goal.toJson(),
      );

      if (response.statusCode == 201) {
        final responseModel = ResponseModel<GoalModel>.fromJson(
          response.data,
          (json) => GoalModel.fromJson(json),
        );
        return Right(responseModel);
      } else {
        return const Left('Failed to create goal');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, GoalIndicatorModel>> getGoalIndicators(
      String goalId) async {
    try {
      final response = await dio.get('${ApiConst.goals}/$goalId/indicators');

      if (response.statusCode == 200) {
        return Right(GoalIndicatorModel.fromJson(response.data));
      } else {
        return const Left('Failed to fetch goal indicators');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
