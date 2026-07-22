import 'package:flutter_test/flutter_test.dart';
import 'package:jaidem/features/stories/data/models/story_model.dart';

void main() {
  test('StoryGroupModel.fromJson разбирает автора и список сторисов', () {
    final json = {
      'author': {
        'id': 12,
        'fullname': 'Айбек',
        'avatar': 'https://example.com/a.jpg',
        'isAdvisor': true,
      },
      'stories': [
        {'id': 340, 'photo': 'https://example.com/1.jpg', 'created_at': '2026-07-22T09:14:00Z'},
        {'id': 341, 'photo': 'https://example.com/2.jpg', 'created_at': '2026-07-22T10:02:00Z'},
      ],
    };

    final group = StoryGroupModel.fromJson(json);

    expect(group.author.id, 12);
    expect(group.author.fullname, 'Айбек');
    expect(group.author.isAdvisor, isTrue);
    expect(group.stories.map((s) => s.id).toList(), [340, 341]);
    expect(group.stories.first.photo, 'https://example.com/1.jpg');
    expect(group.stories.last.createdAt.toUtc().hour, 10);
  });

  test('StoryAuthorModel.fromJson переживает отсутствующие поля', () {
    final author = StoryAuthorModel.fromJson({'id': 5});

    expect(author.id, 5);
    expect(author.fullname, isNull);
    expect(author.avatar, isNull);
    expect(author.isAdvisor, isFalse);
  });
}
