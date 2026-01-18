import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/events/data/datasources/event_remote_data_source.dart';
import 'package:jaidem/features/events/data/mappers/event_mapper.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;
  final SharedPreferences prefs;

  const EventRemoteDataSourceImpl({
    required this.dio,
    required this.prefs,
  });

  @override
  Future<Either<String, List<EventModel>>> getEvents() async {
    try {
      final Map<String, dynamic> queryParams = {};

      final response = await dio.get(
        ApiConst.event,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final responseModel = ResponseModel<EventModel>.fromJson(
          response.data,
          (json) => EventMapper.fromJson(json),
        );
        return Right(responseModel.results);
      } else {
        return Left('Failed to fetch forums');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, AttendanceModel?>> getAttendance(
      int eventId, String studentId) async {
    try {
      final response = await dio.get(
        ApiConst.attendance,
        queryParameters: {
          'event': eventId,
          'student': studentId,
        },
      );
      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final attendanceJson = results.first as Map<String, dynamic>;
          final attendance = AttendanceModel(
            id: attendanceJson['id'] as int?,
            status: attendanceJson['status'] as String? ?? '',
            reason: attendanceJson['reason'] as String? ?? '',
            createdAt: attendanceJson['created_at'] as String?,
            student: studentId,
            event: eventId,
          );
          return Right(attendance);
        }
        return const Right(null);
      } else {
        return const Right(null);
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> sendAttendance(
      AttendanceModel attendance) async {
    try {
      final userId = prefs.getString(AppConstants.userId);

      attendance = attendance.copyWith(student: userId);

      final response = await dio.post(
        ApiConst.attendance,
        data: attendance.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        return Left('Не получилось отправить запрос, попробуйте позже');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> updateAttendance(
      AttendanceModel attendance) async {
    try {
      final userId = prefs.getString(AppConstants.userId);

      attendance = attendance.copyWith(student: userId);

      final response = await dio.patch(
        '${ApiConst.attendance}${attendance.id}/',
        data: attendance.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        return Left('Не получилось обновить ответ, попробуйте позже');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
