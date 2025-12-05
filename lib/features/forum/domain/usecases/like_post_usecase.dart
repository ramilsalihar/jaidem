import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/data/datasources/forum_remote_data_source.dart';

class LikePostUsecase {
  final ForumRemoteDataSource repository;

  LikePostUsecase(this.repository);

  Future<Either<String, int>> call(int forumId) {
    return repository.likeForum(forumId);
  }
}
