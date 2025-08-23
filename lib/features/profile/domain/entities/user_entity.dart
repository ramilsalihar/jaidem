class UserEntity {
  final int id;
  final String? fullname;
  final String? avatar;
  final String userType;
  final DateTime dateCreated;
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

  UserEntity({
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

  UserEntity copyWith({
    int? id,
    String? fullname,
    String? avatar,
    String? userType,
    DateTime? dateCreated,
    String? phone,
    int? age,
    String? university,
    String? login,
    String? password,
    int? courseYear,
    String? speciality,
    String? email,
    Map<String, dynamic>? socialMedias,
    String? interest,
    String? skills,
    int? flow,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      avatar: avatar ?? this.avatar,
      userType: userType ?? this.userType,
      dateCreated: dateCreated ?? this.dateCreated,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      university: university ?? this.university,
      login: login ?? this.login,
      password: password ?? this.password,
      courseYear: courseYear ?? this.courseYear,
      speciality: speciality ?? this.speciality,
      email: email ?? this.email,
      socialMedias: socialMedias ?? this.socialMedias,
      interest: interest ?? this.interest,
      skills: skills ?? this.skills,
      flow: flow ?? this.flow,
    );
  }
}
