import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';

class SendAttendanceUsecase {
  final EventRepository repository;

  const SendAttendanceUsecase(this.repository);

  Future<Either<String, void>> call(AttendanceModel attendance) {
    return repository.sendAttendance(attendance);
  }
}
