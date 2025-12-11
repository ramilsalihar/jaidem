import 'package:dartz/dartz.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  UpdateEventUseCase(this.repository);

  Future<Either<String, void>> call(EventEntity event) {
    return repository.updateEvent(event);
  }
}
