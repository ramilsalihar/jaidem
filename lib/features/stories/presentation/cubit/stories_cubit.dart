import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/stories/data/datasources/seen_stories_store.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';
import 'package:jaidem/features/stories/domain/story_ordering.dart';
import 'package:jaidem/features/stories/domain/usecases/stories_usecase.dart';

part 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesUsecase storiesUsecase;
  final SeenStoriesStore seenStore;

  StoriesCubit({required this.storiesUsecase, required this.seenStore})
      : super(StoriesInitial());

  int? currentUserId;

  /// Загружает ленту. Ошибку не выбрасываем наверх баннером: сторисы —
  /// второстепенный контент и не должны ломать страницу Жайдемчилер.
  Future<void> fetchFeed() async {
    if (state is! StoriesLoaded) emit(StoriesLoading());

    final result = await storiesUsecase.getStories();

    await result.fold(
      (failure) async => emit(StoriesError(message: failure)),
      (groups) async {
        final activeIds = groups
            .expand((g) => g.stories)
            .map((s) => s.id)
            .toSet();
        await seenStore.pruneTo(activeIds);
        final seen = seenStore.read();

        emit(StoriesLoaded(
          groups: sortStoryGroups(
            groups: groups,
            seenStoryIds: seen,
            currentUserId: currentUserId,
          ),
          seenStoryIds: seen,
        ));
      },
    );
  }

  /// Загружает фото и создаёт сторис. Возвращает true при успехе.
  Future<bool> createStory(File file) async {
    final upload = await storiesUsecase.uploadPhoto(file);
    final url = upload.fold((_) => null, (value) => value);
    if (url == null) return false;

    final created = await storiesUsecase.createStory(url);
    final ok = created.isRight();
    if (ok) await fetchFeed();
    return ok;
  }

  Future<bool> deleteStory(int storyId) async {
    final result = await storiesUsecase.deleteStory(storyId);
    final ok = result.isRight();
    if (ok) await fetchFeed();
    return ok;
  }

  /// Отмечает как просмотренный и обновляет seenStoryIds, но НЕ пересортировывает ленту:
  /// текущий порядок групп переиспользуется, чтобы избежать раздражающих скачков аватаров
  /// во время просмотра сторисов. Порядок обновится на следующем fetchFeed().
  Future<void> markSeen(int storyId) async {
    await seenStore.markSeen(storyId);
    final current = state;
    if (current is StoriesLoaded) {
      emit(StoriesLoaded(
        groups: current.groups,
        seenStoryIds: seenStore.read(),
      ));
    }
  }
}
