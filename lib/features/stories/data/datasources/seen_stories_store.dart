import 'package:shared_preferences/shared_preferences.dart';

/// Локальная отметка «этот сторис уже просмотрен».
///
/// Хранится только на устройстве: счётчик «кто посмотрел» в v1 не делаем,
/// поэтому на сервер эта информация не уходит.
class SeenStoriesStore {
  static const String _key = 'seen_story_ids';

  final SharedPreferences prefs;

  const SeenStoriesStore(this.prefs);

  Set<int> read() {
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> markSeen(int storyId) => _write(read()..add(storyId));

  /// Оставляет только ещё активные id, чтобы набор не рос бесконечно.
  Future<void> pruneTo(Set<int> activeStoryIds) =>
      _write(read().intersection(activeStoryIds));

  Future<void> _write(Set<int> ids) =>
      prefs.setStringList(_key, ids.map((e) => e.toString()).toList());
}
