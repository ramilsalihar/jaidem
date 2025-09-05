import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:jaidem/features/forum/domain/repositories/forum_repository.dart';

class GetForumComment {
  final ForumRepository repository;

  GetForumComment(this.repository);

  Future<Either<String, List<CommentEntity>>> call(int postId) {
    return repository.fetchComments(postId);
  }
}
