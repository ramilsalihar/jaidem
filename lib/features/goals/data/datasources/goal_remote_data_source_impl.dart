import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<Either<String, GoalModel>> createGoal(GoalModel goal) async {
    try {
      final userId = sl<SharedPreferences>().getString(AppConstants.userId);

      goal = goal.copyWith(student: userId);

      final response = await dio.post(
        ApiConst.goals,
        data: goal.toJson(),
      );

      if ([200, 201].contains(response.statusCode)) {
        final responseModel = GoalModel.fromJson(response.data);
        return Right(responseModel);
      } else {
        return const Left('Failed to create goal');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, ResponseModel<GoalIndicatorModel>>> getGoalIndicators(
    String goalId,
  ) async {
    try {
      final url = '${ApiConst.indicators}?goal=$goalId';

      final response = await dio.get(url);

      if ([200, 201].contains(response.statusCode)) {
        final data = response.data;

        final responseModel = ResponseModel<GoalIndicatorModel>.fromJson(
          data,
          (json) => GoalIndicatorModel.fromJson(json),
        );

        return Right(responseModel);
      } else {
        return const Left('Failed to fetch goal indicators');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, GoalIndicatorModel>> createGoalIndicator(
      GoalIndicatorModel indicator) async {
    try {
      final response = await dio.post(
        ApiConst.indicators,
        data: indicator.toJson(),
      );

      if ([200, 201].contains(response.statusCode)) {
        return Right(GoalIndicatorModel.fromJson(response.data));
      } else {
        return const Left('Failed to create goal indicator');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
