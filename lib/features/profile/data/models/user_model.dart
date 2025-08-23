class UserModel {
  final int id;
  final String? fullname;
  final String? avatar;
  final String userType;
  final String dateCreated;
  final String? phone;
  final int age;
  final String? university;
  final String login;
  final String password;
  final int courseYear;
  final String? speciality;
  final String? email;
  final Map<String, dynamic>? socialMedias;
  final String? interest;
  final String? skills;
  final int? flow;

  UserModel({
    required this.id,
    this.fullname,
    this.avatar,
    required this.userType,
    required this.dateCreated,
    this.phone,
    required this.age,
    this.university,
    required this.login,
    required this.password,
    required this.courseYear,
    this.speciality,
    this.email,
    this.socialMedias,
    this.interest,
    this.skills,
    this.flow,
  });

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
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

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'avatar': avatar,
      'user_type': userType,
      'date_created': dateCreated,
      'phone': phone,
      'age': age,
      'university': university,
      'login': login,
      'password': password,
      'course_year': courseYear,
      'speciality': speciality,
      'email': email,
      'social_medias': socialMedias,
      'interest': interest,
      'skills': skills,
      'flow': flow,
    };
  }
}
