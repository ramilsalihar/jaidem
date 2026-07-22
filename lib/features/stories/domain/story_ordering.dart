import 'package:jaidem/features/stories/data/models/story_model.dart';

/// Раскладывает ленту по трём корзинам: свои → непросмотренные → просмотренные.
///
/// Сервер отдаёт группы по свежести и ничего не знает про «просмотрено»
/// (оно локальное), поэтому финальный порядок задаётся здесь. Внутри каждой
/// корзины исходный порядок по свежести сохраняется.
///
/// Попутно отфильтровывает группы без сторисов (`group.stories.isEmpty`):
/// такой группе нечего показывать во вьювере, и без фильтрации пустой список
/// сторисов проходил бы `.every(...)` как «просмотренный», попадал в корзину
/// «просмотренные», а открытие вьювера на нём падало с RangeError.
List<StoryGroupModel> sortStoryGroups({
  required List<StoryGroupModel> groups,
  required Set<int> seenStoryIds,
  required int? currentUserId,
}) {
  final own = <StoryGroupModel>[];
  final unseen = <StoryGroupModel>[];
  final seen = <StoryGroupModel>[];

  for (final group in groups) {
    // Группе без сторисов нечего показывать во вьювере — отбрасываем её здесь,
    // чтобы она не дошла ни до ленты, ни до просмотрщика (иначе `.every` на пустом
    // списке даст true и группа попадёт в «просмотренные», а открытие приведёт к RangeError).
    if (group.stories.isEmpty) continue;
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
