import 'package:jaidem/features/forum/data/mappers/author_mapper.dart';
import 'package:jaidem/features/forum/data/models/comment_model.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';

class CommentMapper {
  static CommentModel fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      author: json['author'],
      post: json['post'],
      content: json['content'],
      createdAt: json['date_created'],
    );
  }

  static CommentModel fromComment(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      author: AuthorMapper.fromJson(json['author']),
      post: json['post'],
      content: json['content'],
      createdAt: json['date_created'],
    );
  }

  static Map<String, dynamic> toJson(CommentModel comment) {
    return {
      'author': comment.author,
      'post': comment.post,
      'content': comment.content,
    };
  }

  static CommentEntity toEntity(CommentModel model) {
    return CommentEntity(
      id: model.id,
      author: model.author,
      post: model.post,
      content: model.content,
      createdAt: model.createdAt,
    );
  }

  static CommentModel fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      author: entity.author,
      post: entity.post,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }
}
