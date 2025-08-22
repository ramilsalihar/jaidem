class JaidemModel {
  final int id;
  final String displayName;
  final String? avatarUrl;
  final DateTime registrationDate;
  final String? phoneNumber;
  final int age;
  final String university;
  final String username;
  final int academicYear;
  final String specialization;
  final String? emailAddress;
  final dynamic socialLinks;
  final List<String> interests;
  final List<String> skillSet;
  final int? streamNumber;
  final String? cohort;
  final int? region;

  const JaidemModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.registrationDate,
    this.phoneNumber,
    required this.age,
    required this.university,
    required this.username,
    required this.academicYear,
    required this.specialization,
    this.emailAddress,
    required this.socialLinks,
    required this.interests,
    required this.skillSet,
    this.streamNumber,
    this.cohort,
    this.region,
  });

  JaidemModel copyWith({
    int? id,
    String? displayName,
    String? avatarUrl,
    DateTime? registrationDate,
    String? phoneNumber,
    int? age,
    String? university,
    String? username,
    int? academicYear,
    String? specialization,
    String? emailAddress,
    dynamic socialLinks,
    List<String>? interests,
    List<String>? skillSet,
    int? streamNumber,
    String? cohort,
    int? region,
  }) {
    return JaidemModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      registrationDate: registrationDate ?? this.registrationDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      university: university ?? this.university,
      username: username ?? this.username,
      academicYear: academicYear ?? this.academicYear,
      specialization: specialization ?? this.specialization,
      emailAddress: emailAddress ?? this.emailAddress,
      socialLinks: socialLinks ?? this.socialLinks,
      interests: interests ?? this.interests,
      skillSet: skillSet ?? this.skillSet,
      streamNumber: streamNumber ?? this.streamNumber,
      cohort: cohort ?? this.cohort,
      region: region ?? this.region,
    );
  }
}