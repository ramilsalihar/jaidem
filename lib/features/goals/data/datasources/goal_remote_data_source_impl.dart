import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final Dio dio;
  final SharedPreferences prefs;

  const GoalRemoteDataSourceImpl({
    required this.dio,
    required this.prefs,
  });

  @override
  Future<Either<String, ResponseModel<GoalModel>>> getGoals() async {
    try {
      final userId = prefs.getString(AppConstants.userId);

      final response = await dio.get(ApiConst.goals, queryParameters: {
        'student': userId,
      });

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

  @override
  Future<Either<String, GoalTaskModel>> createGoalTask(
      GoalTaskModel task) async {
    try {
      final response = await dio.post(
        ApiConst.tasks,
        data: task.toJson(),
      );

      if ([200, 201].contains(response.statusCode)) {
        return Right(GoalTaskModel.fromJson(response.data));
      } else {
        return const Left('Failed to create goal task');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, ResponseModel<GoalTaskModel>>> getGoalTasks(
    String indicatorId,
  ) async {
    try {
      final url = '${ApiConst.tasks}?indicator=$indicatorId';

      final response = await dio.get(url);

      if ([200, 201].contains(response.statusCode)) {
        final data = response.data;

        final responseModel = ResponseModel<GoalTaskModel>.fromJson(
          data,
          (json) => GoalTaskModel.fromJson(json),
        );

        return Right(responseModel);
      } else {
        return const Left('Failed to fetch goal tasks');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, GoalTaskModel>> updateGoalTask(
    GoalTaskModel task,
  ) async {
    try {
      final response = await dio.patch(
        '${ApiConst.tasks}/${task.id}/',
        data: task.toJson(),
      );

      if ([200, 201].contains(response.statusCode)) {
        return Right(GoalTaskModel.fromJson(response.data));
      } else {
        return const Left('Failed to update goal task');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteGoalIndicator(String indicatorId) async {
    try {
      final response = await dio.delete('${ApiConst.indicators}/$indicatorId/');

      if (response.statusCode == 204) {
        return const Right(null);
      } else {
        return const Left('Failed to delete goal indicator');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, GoalIndicatorModel>> fetchGoalIndicatorById(
      String indicatorId) async {
    try {
      final response = await dio.get('${ApiConst.indicators}/$indicatorId');

      if (response.statusCode == 200) {
        return Right(GoalIndicatorModel.fromJson(response.data));
      } else {
        return const Left('Failed to fetch goal indicator');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, GoalIndicatorModel>> updateGoalIndicator(
    GoalIndicatorModel indicator,
  ) async {
    try {
      final response = await dio.put(
        '${ApiConst.indicators}/${indicator.id}/',
        data: indicator.toJson(),
      );

      if ([200, 201].contains(response.statusCode)) {
        return Right(GoalIndicatorModel.fromJson(response.data));
      } else {
        return const Left('Failed to update goal indicator');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
