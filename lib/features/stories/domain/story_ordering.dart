import 'package:jaidem/features/stories/data/models/story_model.dart';

/// Раскладывает ленту по трём корзинам: свои → непросмотренные → просмотренные.
///
/// Сервер отдаёт группы по свежести и ничего не знает про «просмотрено»
/// (оно локальное), поэтому финальный порядок задаётся здесь. Внутри каждой
/// корзины исходный порядок по свежести сохраняется.
List<StoryGroupModel> sortStoryGroups({
  required List<StoryGroupModel> groups,
  required Set<int> seenStoryIds,
  required int? currentUserId,
}) {
  final own = <StoryGroupModel>[];
  final unseen = <StoryGroupModel>[];
  final seen = <StoryGroupModel>[];

  for (final group in groups) {
    if (currentUserId != null && group.author.id == currentUserId) {
      own.add(group);
    } else if (group.stories.every((s) => seenStoryIds.contains(s.id))) {
      // Группа считается просмотренной, только если просмотрены все её сторисы.
      seen.add(group);
    } else {
      unseen.add(group);
    }
  }

  return [...own, ...unseen, ...seen];
}
