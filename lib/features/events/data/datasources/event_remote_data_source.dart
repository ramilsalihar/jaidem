import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<Either<String, List<EventModel>>> getEvents();

  Future<Either<String, void>> sendAttendance(AttendanceModel attendance);
}
