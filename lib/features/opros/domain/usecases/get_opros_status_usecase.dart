import 'package:dartz/dartz.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';
import 'package:jaidem/features/opros/domain/repositories/opros_repository.dart';

class GetOprosStatusUseCase {
  final OprosRepository repository;

  const GetOprosStatusUseCase(this.repository);

  Future<Either<String, OprosStatusModel>> call() async {
    return await repository.getOprosStatus();
  }
}
