import 'package:dartz/dartz.dart';
import 'package:jaidem/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:jaidem/features/forum/data/mappers/comment_mapper.dart';
import 'package:jaidem/features/forum/data/mappers/forum_mapper.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/domain/repositories/forum_repository.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';

class ForumRepositoryImpl implements ForumRepository {
  final ForumRemoteDataSource remoteDataSource;

  ForumRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<String, List<ForumEntity>>> fetchAllForums(
      String? search) async {
    final result = await remoteDataSource.fetchAllForums(search);
    return result.map((forums) =>
        forums.map((forum) => ForumMapper.toEntity(forum)).toList());
  }

  @override
  Future<Either<String, List<CommentEntity>>> fetchComments(int postId) async {
    final result = await remoteDataSource.fetchComments(postId);
    return result.map((comments) =>
        comments.map((comment) => CommentMapper.toEntity(comment)).toList());
  }

  @override
  Future<Either<String, CommentEntity>> postComment(
      {required CommentEntity comment}) async {
    final result = await remoteDataSource.postComment(
        comment: CommentMapper.fromEntity(comment));
    return result.map((comment) => CommentMapper.toEntity(comment));
  }
}
