import 'package:jaidem/features/forum/data/models/forum_model.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';

class ForumMapper {
  static ForumModel fromJson(Map<String, dynamic> json) {
    return ForumModel(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  static ForumEntity toEntity(ForumModel model) {
    return ForumEntity(
      id: model.id,
      author: model.author,
      title: model.title,
      content: model.content,
      createdAt: model.createdAt,
    );
  }
}
