import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<String, List<EventEntity>>> getEvents();

  Future<Either<String, void>> sendAttendance(AttendanceModel attendance);
}
