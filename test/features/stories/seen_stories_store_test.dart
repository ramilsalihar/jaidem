import 'package:flutter_test/flutter_test.dart';
import 'package:jaidem/features/stories/data/datasources/seen_stories_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('markSeen сохраняет id, read его возвращает', () async {
    final store = SeenStoriesStore(prefs);

    await store.markSeen(10);
    await store.markSeen(11);

    expect(store.read(), {10, 11});
  });

  test('markSeen не создаёт дублей', () async {
    final store = SeenStoriesStore(prefs);

    await store.markSeen(10);
    await store.markSeen(10);

    expect(store.read(), {10});
  });

  test('pruneTo оставляет только активные id', () async {
    final store = SeenStoriesStore(prefs);
    await store.markSeen(10);
    await store.markSeen(11);
    await store.markSeen(12);

    await store.pruneTo({11, 12, 99});

    expect(store.read(), {11, 12});
  });

  test('данные persisted в SharedPreferences и читаются новым экземпляром store', () async {
    final store1 = SeenStoriesStore(prefs);
    await store1.markSeen(10);
    await store1.markSeen(11);

    // Создаём новый экземпляр store над той же SharedPreferences инстанцией
    final store2 = SeenStoriesStore(prefs);
    expect(store2.read(), {10, 11});
  });

  test('pruneTo persisted и читаются новым экземпляром store', () async {
    final store1 = SeenStoriesStore(prefs);
    await store1.markSeen(10);
    await store1.markSeen(11);
    await store1.markSeen(12);
    await store1.pruneTo({11, 12});

    // Создаём новый экземпляр store над той же SharedPreferences инстанцией
    final store2 = SeenStoriesStore(prefs);
    expect(store2.read(), {11, 12});
  });

  test('некорректные данные в хранилище игнорируются', () async {
    // Напрямую устанавливаем в SharedPreferences некорректные данные
    SharedPreferences.setMockInitialValues({
      'seen_story_ids': ['10', 'not-a-number', '12', 'invalid', '14']
    });
    prefs = await SharedPreferences.getInstance();

    final store = SeenStoriesStore(prefs);
    expect(store.read(), {10, 12, 14});
  });
}
