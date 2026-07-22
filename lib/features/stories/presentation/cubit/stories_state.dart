part of 'stories_cubit.dart';

abstract class StoriesState extends Equatable {
  const StoriesState();

  @override
  List<Object?> get props => [];
}

class StoriesInitial extends StoriesState {}

class StoriesLoading extends StoriesState {}

class StoriesLoaded extends StoriesState {
  final List<StoryGroupModel> groups;
  final Set<int> seenStoryIds;

  const StoriesLoaded({required this.groups, required this.seenStoryIds});

  @override
  List<Object?> get props => [groups, seenStoryIds];
}

class StoriesError extends StoriesState {
  final String message;

  const StoriesError({required this.message});

  @override
  List<Object?> get props => [message];
}
