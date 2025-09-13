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
}
