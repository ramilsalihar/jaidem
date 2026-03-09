import 'package:jaidem/features/forum/data/models/author_model.dart';
import 'package:jaidem/features/forum/domain/entities/author_entity.dart';

class AuthorMapper {
  static AuthorModel fromJson(Map<String, dynamic> json) {
    final flow = json['flow'];
    String? flowName;
    if (flow is Map<String, dynamic>) {
      flowName = flow['name'] as String?;
    }
    return AuthorModel(
      id: json['id'],
      fullname: json['fullname'],
      avatar: json['avatar'],
      flowName: flowName,
    );
  }

  static AuthorEntity toEntity(AuthorModel model) {
    return AuthorEntity(
      id: model.id,
      fullname: model.fullname,
      avatar: model.avatar,
      flowName: model.flowName,
    );
  }

  static AuthorModel toModel(AuthorEntity entity) {
    return AuthorModel(
      id: entity.id,
      fullname: entity.fullname,
      avatar: entity.avatar,
      flowName: entity.flowName,
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
