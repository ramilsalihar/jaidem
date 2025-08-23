import 'package:jaidem/features/profile/data/models/user_model.dart';
import 'package:jaidem/features/profile/domain/entities/user_entity.dart';

class UserMapper {
  /// Model → Entity
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      fullname: model.fullname,
      avatar: model.avatar,
      userType: model.userType,
      dateCreated: DateTime.parse(model.dateCreated),
      phone: model.phone,
      age: model.age,
      university: model.university,
      login: model.login,
      password: model.password,
      courseYear: model.courseYear,
      speciality: model.speciality,
      email: model.email,
      socialMedias: model.socialMedias,
      interest: model.interest,
      skills: model.skills,
      flow: model.flow,
    );
  }

  /// Entity → Model
  static UserModel fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullname: entity.fullname,
      avatar: entity.avatar,
      userType: entity.userType,
      dateCreated: entity.dateCreated.toIso8601String(),
      phone: entity.phone,
      age: entity.age,
      university: entity.university,
      login: entity.login,
      password: entity.password,
      courseYear: entity.courseYear,
      speciality: entity.speciality,
      email: entity.email,
      socialMedias: entity.socialMedias,
      interest: entity.interest,
      skills: entity.skills,
      flow: entity.flow,
    );
  }

  // From Json
  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String?,
      avatar: json['avatar'] as String?,
      userType: json['user_type'] as String,
      dateCreated: json['date_created'] as String,
      phone: json['phone'] as String?,
      age: json['age'] as int,
      university: json['university'] as String?,
      login: json['login'] as String,
      password: json['password'] as String,
      courseYear: json['course_year'] as int,
      speciality: json['speciality'] as String?,
      email: json['email'] as String?,
      socialMedias: json['social_medias'] as Map<String, dynamic>?,
      interest: json['interest'] as String?,
      skills: json['skills'] as String?,
      flow: json['flow'] as int?,
    );
  }

  // toJson
  static Map<String, dynamic> toJson(UserModel model) {
    return {
      'id': model.id,
      'fullname': model.fullname,
      'avatar': model.avatar,
      'user_type': model.userType,
      'date_created': model.dateCreated,
      'phone': model.phone,
      'age': model.age,
      'university': model.university,
      'login': model.login,
      'password': model.password,
      'course_year': model.courseYear,
      'speciality': model.speciality,
      'email': model.email,
      'social_medias': model.socialMedias,
      'interest': model.interest,
      'skills': model.skills,
      'flow': model.flow,
    };
  }
}
