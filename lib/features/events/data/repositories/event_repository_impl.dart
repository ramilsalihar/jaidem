import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/data/datasources/event_remote_data_source.dart';
import 'package:jaidem/features/events/data/mappers/event_mapper.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  const EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<EventEntity>>> getEvents() async {
    final result = await remoteDataSource.getEvents();

    return result.fold(
      (failure) => Left(failure),
      (models) {
        final entities = models
            .map((EventModel model) => EventMapper.toEntity(model))
            .toList();
        return Right(entities);
      },
    );
  }

  @override
  Future<Either<String, AttendanceModel?>> getAttendance(
      int eventId, String studentId) {
    return remoteDataSource.getAttendance(eventId, studentId);
  }

  @override
  Future<Either<String, void>> sendAttendance(AttendanceModel attendance) {
    return remoteDataSource.sendAttendance(attendance);
  }

  @override
  Future<Either<String, void>> updateEvent(EventEntity event) {
    return remoteDataSource.updateEvent(EventMapper.toModel(event));
  }
}
