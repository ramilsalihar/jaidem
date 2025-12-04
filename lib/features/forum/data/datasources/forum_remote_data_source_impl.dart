import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:jaidem/features/forum/data/mappers/comment_mapper.dart';
import 'package:jaidem/features/forum/data/mappers/forum_mapper.dart';
import 'package:jaidem/features/forum/data/models/comment_model.dart';
import 'package:jaidem/features/forum/data/models/forum_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForumRemoteDataSourceImpl implements ForumRemoteDataSource {
  final Dio dio;
  final SharedPreferences prefs;

  ForumRemoteDataSourceImpl(this.dio, this.prefs);

  @override
  Future<Either<String, List<ForumModel>>> fetchAllForums(
    String? search,
  ) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (search != null) {
        queryParams['search'] = search;
      }
      final response = await dio.get(
        ApiConst.forum,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final responseModel = ResponseModel<ForumModel>.fromJson(
          response.data,
          (json) => ForumMapper.fromJson(json),
        );

        return Right(responseModel.results);
      } else {
        return Left('Failed to fetch forums');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, List<CommentModel>>> fetchComments(int postId) async {
    try {
      final response = await dio.get(
        ApiConst.comments,
        queryParameters: {
          'post': postId,
        },
      );
      if (response.statusCode == 200) {
        final responseModel = ResponseModel<CommentModel>.fromJson(
          response.data,
          (json) => CommentMapper.fromComment(json),
        );
        return Right(responseModel.results);
      } else {
        return Left('Failed to fetch comments');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, CommentModel>> postComment({
    required CommentModel comment,
  }) async {
    try {
      final userId = prefs.getString(AppConstants.userId);
      if (userId != null) {
        comment = comment.copyWith(author: userId);
      }

      final response = await dio.post(
        ApiConst.comments,
        data: CommentMapper.toJson(comment),
      );
      if (response.statusCode == 201) {
        return Right(CommentMapper.fromJson(response.data));
      } else {
        return Left('Failed to post comment');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
