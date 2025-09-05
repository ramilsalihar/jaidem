import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:jaidem/features/forum/domain/repositories/forum_repository.dart';

class PostForumComment {
  final ForumRepository repository;

  PostForumComment(this.repository);

  Future<Either<String, CommentEntity>> call({required CommentEntity comment}) {
    return repository.postComment(comment: comment);
  }
}
