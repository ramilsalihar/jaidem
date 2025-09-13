import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';

class GetEventsUsecase {
  final EventRepository repository;

  const GetEventsUsecase(this.repository);

  Future<Either<String, List<EventEntity>>> call() {
    return repository.getEvents();
  }
}
