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
}
