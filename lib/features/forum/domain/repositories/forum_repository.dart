import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';

abstract class ForumRepository {
  Future<Either<String, List<ForumEntity>>> fetchAllForums();

  Future<Either<String, List<CommentEntity>>> fetchComments(int postId);

  Future<Either<String, CommentEntity>> postComment({
    required CommentEntity comment,
  });
}
