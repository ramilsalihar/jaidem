import 'package:jaidem/features/forum/data/mappers/author_mapper.dart';
import 'package:jaidem/features/forum/data/models/forum_model.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';

class ForumMapper {
  static ForumModel fromJson(Map<String, dynamic> json) {
    return ForumModel(
      id: json['id'],
      author: json['author'] != null
          ? AuthorMapper.fromJson(json['author'])
          : null,
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      photo: json['photo'],
      likesCount: json['likes_count'],
      likedUsers: (json['liked_users'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  static Map<String, dynamic> toJson(ForumModel model) {
    return {
      'id': model.id,
      'author': model.author != null ? AuthorMapper.toJson(model.author!) : null,
      'title': model.title,
      'content': model.content,
      'created_at': model.createdAt,
      'photo': model.photo,
      'likes_count': model.likesCount,
      'liked_users': model.likedUsers,
    };
  }

  static ForumEntity toEntity(ForumModel model) {
    return ForumEntity(
      id: model.id,
      author:
          model.author != null ? AuthorMapper.toEntity(model.author!) : null,
      title: model.title,
      content: model.content,
      createdAt: model.createdAt,
      photo: model.photo,
      likesCount: model.likesCount,
      likedUsers: model.likedUsers,
    );
  }

  static ForumModel toModel(ForumEntity entity) {
    return ForumModel(
      id: entity.id,
      author:
          entity.author != null ? AuthorMapper.toModel(entity.author!) : null,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      photo: entity.photo,
      likesCount: entity.likesCount,
      likedUsers: entity.likedUsers,
    );
  }
}
