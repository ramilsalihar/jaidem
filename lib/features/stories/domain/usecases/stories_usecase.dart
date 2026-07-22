import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:jaidem/features/stories/data/datasources/stories_remote_data_source.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';

class StoriesUsecase {
  final StoriesRemoteDataSource repository;

  const StoriesUsecase(this.repository);

  Future<Either<String, List<StoryGroupModel>>> getStories() =>
      repository.getStories();

  Future<Either<String, String>> uploadPhoto(File file) =>
      repository.uploadPhoto(file);

  Future<Either<String, StoryModel>> createStory(String photoUrl) =>
      repository.createStory(photoUrl);

  Future<Either<String, Unit>> deleteStory(int storyId) =>
      repository.deleteStory(storyId);
}
