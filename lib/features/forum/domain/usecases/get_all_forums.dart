import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/domain/repositories/forum_repository.dart';

class GetAllForums {
  final ForumRepository repository;

  GetAllForums(this.repository);

  Future<Either<String, List<ForumEntity>>> call(String? search) {
    return repository.fetchAllForums(search);
  }
}
