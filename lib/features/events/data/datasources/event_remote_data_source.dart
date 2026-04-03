import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<Either<String, List<EventModel>>> getEvents({int? flowId});

  Future<Either<String, AttendanceModel?>> getAttendance(int eventId, String studentId);

  Future<Either<String, EventAttendancesResponse>> getEventAttendances(int eventId);

  Future<Either<String, void>> sendAttendance(AttendanceModel attendance);

  Future<Either<String, void>> updateAttendance(AttendanceModel attendance);
}
