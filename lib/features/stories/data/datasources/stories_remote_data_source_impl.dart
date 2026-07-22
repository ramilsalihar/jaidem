import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/stories/data/datasources/stories_remote_data_source.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';

class StoriesRemoteDataSourceImpl implements StoriesRemoteDataSource {
  final Dio dio;

  const StoriesRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<String, List<StoryGroupModel>>> getStories() async {
    try {
      final response = await dio.get(ApiConst.stories);
      final data = (response.data as List<dynamic>)
          .map((e) => StoryGroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(data);
    } catch (e) {
      return Left('Failed to load stories: $e');
    }
  }

  @override
  Future<Either<String, String>> uploadPhoto(File file) async {
    try {
      final formData = FormData.fromMap({
        'title': 'story_${DateTime.now().millisecondsSinceEpoch}',
        'image': await MultipartFile.fromFile(file.path, filename: 'story.jpg'),
      });

      final response = await dio.post(ApiConst.imageUpload, data: formData);
      final url = response.data['image'] as String?;
      if (url == null || url.isEmpty) {
        return const Left('Upload returned no image url');
      }
      return Right(url);
    } catch (e) {
      return Left('Failed to upload photo: $e');
    }
  }

  @override
  Future<Either<String, StoryModel>> createStory(String photoUrl) async {
    try {
      final response = await dio.post(ApiConst.stories, data: {'photo': photoUrl});
      return Right(StoryModel.fromJson(response.data as Map<String, dynamic>));
    } catch (e) {
      return Left('Failed to create story: $e');
    }
  }

  @override
  Future<Either<String, Unit>> deleteStory(int storyId) async {
    try {
      await dio.delete('${ApiConst.stories}$storyId/');
      return const Right(unit);
    } catch (e) {
      return Left('Failed to delete story: $e');
    }
  }
}
