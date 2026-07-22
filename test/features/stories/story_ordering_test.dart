import 'package:flutter_test/flutter_test.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';
import 'package:jaidem/features/stories/domain/story_ordering.dart';

StoryGroupModel _group(int authorId, List<int> storyIds) {
  return StoryGroupModel(
    author: StoryAuthorModel(id: authorId, isAdvisor: false),
    stories: storyIds
        .map((id) => StoryModel(id: id, photo: '', createdAt: DateTime(2026, 7, 22)))
        .toList(),
  );
}

void main() {
  test('свои идут первыми, затем непросмотренные, затем просмотренные', () {
    final groups = [
      _group(1, [100]), // просмотрен целиком
      _group(2, [200]), // непросмотрен
      _group(3, [300]), // свой
    ];

    final result = sortStoryGroups(
      groups: groups,
      seenStoryIds: {100},
      currentUserId: 3,
    );

    expect(result.map((g) => g.author.id).toList(), [3, 2, 1]);
  });

  test('группа просмотрена, только если просмотрены все её сторисы', () {
    final groups = [
      _group(1, [100, 101]), // просмотрен лишь частично → считается непросмотренным
      _group(2, [200, 201]), // просмотрен полностью
      _group(3, [300]),      // не просмотрен вообще
    ];

    final result = sortStoryGroups(
      groups: groups,
      seenStoryIds: {100, 200, 201},
      currentUserId: 999,
    );

    // Ожидаемый порядок: частично просмотренная → не просмотренная → полностью просмотренная
    expect(result.map((g) => g.author.id).toList(), [1, 3, 2]);
  });

  test('внутри корзины сохраняется исходный порядок', () {
    final groups = [_group(1, [100]), _group(2, [200]), _group(3, [300])];

    final result = sortStoryGroups(
      groups: groups,
      seenStoryIds: const {},
      currentUserId: null,
    );

    expect(result.map((g) => g.author.id).toList(), [1, 2, 3]);
  });

  test('группа без сторисов отбрасывается целиком', () {
    final groups = [
      _group(1, [100]),
      _group(2, []), // без сторисов — нечего показывать
      _group(3, [300]),
    ];

    final result = sortStoryGroups(
      groups: groups,
      seenStoryIds: const {},
      currentUserId: null,
    );

    expect(result.map((g) => g.author.id).toList(), [1, 3]);
  });

  test(
      'пустая группа отбрасывается, даже если принадлежит текущему пользователю',
      () {
    final groups = [
      _group(1, [100]),
      _group(2, []), // свой, но без сторисов — тоже отбрасывается
    ];

    final result = sortStoryGroups(
      groups: groups,
      seenStoryIds: const {},
      currentUserId: 2,
    );

    expect(result.map((g) => g.author.id).toList(), [1]);
  });
}
