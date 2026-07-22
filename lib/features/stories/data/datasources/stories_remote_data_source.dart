import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';

abstract class StoriesRemoteDataSource {
  Future<Either<String, List<StoryGroupModel>>> getStories();

  /// Загружает файл и возвращает URL картинки.
  Future<Either<String, String>> uploadPhoto(File file);

  Future<Either<String, StoryModel>> createStory(String photoUrl);

  Future<Either<String, Unit>> deleteStory(int storyId);
}
