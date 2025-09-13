import 'package:jaidem/features/forum/data/models/author_model.dart';
import 'package:jaidem/features/forum/domain/entities/author_entity.dart';

class AuthorMapper {
  static AuthorModel fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'],
      fullname: json['fullname'],
      avatar: json['avatar'],
    );
  }

  static AuthorEntity toEntity(AuthorModel model) {
    return AuthorEntity(
      id: model.id,
      fullname: model.fullname,
      avatar: model.avatar,
    );
  }

  static AuthorModel toModel(AuthorEntity entity) {
    return AuthorModel(
      id: entity.id,
      fullname: entity.fullname,
      avatar: entity.avatar,
    );
  }

  static Map<String, dynamic> toJson(AuthorModel model) {
    return {
      'id': model.id,
      'fullname': model.fullname,
      'avatar': model.avatar,
    };
  }
}
