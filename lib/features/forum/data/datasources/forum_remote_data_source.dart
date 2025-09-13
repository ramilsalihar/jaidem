import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/data/models/comment_model.dart';
import 'package:jaidem/features/forum/data/models/forum_model.dart';

abstract class ForumRemoteDataSource {
  Future<Either<String, List<ForumModel>>> fetchAllForums(String? search);

  Future<Either<String, CommentModel>> postComment({
    required CommentModel comment,
  });

  Future<Either<String, List<CommentModel>>> fetchComments(int postId);
}
