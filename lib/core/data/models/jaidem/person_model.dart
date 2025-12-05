import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/region_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/state_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/village_model.dart';

class PersonModel {
  final int id;
  final String? fullname;
  final String? avatar;
  final String? userType;
  final DateTime dateCreated;
  final String? phone;
  final int age;
  final String? university;
  final String login;
  final int courseYear;
  final String? speciality;
  final String? email;
  final Map<String, dynamic>? socialMedias;
  final String? interest;
  final String? skills;
  final FlowModel flow;
  final String? generation;
  final StateModel state;
  final String? aboutMe;
  final bool isActive;
  final double activity;
  final int visit;
  final double progress;
  final List<num>? rewards;
  final RegionModel? region;
  final VillageModel? village;
  final bool block;

  const PersonModel({
    required this.id,
    this.fullname,
    this.avatar,
    this.userType,
    required this.dateCreated,
    this.phone,
    required this.age,
    this.university,
    required this.login,
    required this.courseYear,
    this.speciality,
    this.email,
    this.socialMedias,
    this.interest,
    this.skills,
    required this.flow,
    this.generation,
    required this.state,
    this.aboutMe,
    required this.isActive,
    required this.activity,
    required this.visit,
    required this.progress,
    this.rewards,
    this.region,
    this.village,
    required this.block,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String?,
      avatar: json['avatar'] as String?,
      userType: json['user_type'] as String?,
      dateCreated: DateTime.parse(json['date_created'] as String),
      phone: json['phone'] as String?,
      age: json['age'] as int,
      university: json['university'] as String?,
      login: json['login'] as String,
      courseYear: json['course_year'] as int,
      speciality: json['speciality'] as String?,
      email: json['email'] as String?,
      socialMedias: json['social_medias'] is Map ? json['social_medias'] : {},
      interest: json['interest'] as String?,
      skills: json['skills'] as String?,
      flow: json['flow'] != null
          ? FlowModel.fromJson(json['flow'])
          : FlowModel.empty(),
      generation: json['generation'] as String?,
      state: json['state'] != null
          ? StateModel.fromJson(json['state'])
          : StateModel.empty(),
      aboutMe: json['aboutMe'] as String?,
      isActive: json['is_active'] as bool,
      activity: (json['activity'] as num).toDouble(),
      visit: json['visit'] as int,
      progress: (json['progress'] as num).toDouble(),
      rewards:
          (json['rewards'] as List<dynamic>?)?.map((e) => e as num).toList(),
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      village: json['village'] != null
          ? VillageModel.fromJson(json['village'] as Map<String, dynamic>)
          : null,
      block: json['block'] as bool,
    );
  }

  PersonModel copyWith({
    int? id,
    String? fullname,
    String? avatar,
    String? userType,
    DateTime? dateCreated,
    String? phone,
    int? age,
    String? university,
    String? login,
    int? courseYear,
    String? speciality,
    String? email,
    Map<String, dynamic>? socialMedias,
    String? interest,
    String? skills,
    FlowModel? flow,
    String? generation,
    StateModel? state,
    String? aboutMe,
    bool? isActive,
    double? activity,
    int? visit,
    double? progress,
    List<num>? rewards,
    RegionModel? region,
    VillageModel? village,
    bool? block,
  }) {
    return PersonModel(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      avatar: avatar ?? this.avatar,
      userType: userType ?? this.userType,
      dateCreated: dateCreated ?? this.dateCreated,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      university: university ?? this.university,
      login: login ?? this.login,
      courseYear: courseYear ?? this.courseYear,
      speciality: speciality ?? this.speciality,
      email: email ?? this.email,
      socialMedias: socialMedias ?? this.socialMedias,
      interest: interest ?? this.interest,
      skills: skills ?? this.skills,
      flow: flow ?? this.flow,
      generation: generation ?? this.generation,
      state: state ?? this.state,
      aboutMe: aboutMe ?? this.aboutMe,
      isActive: isActive ?? this.isActive,
      activity: activity ?? this.activity,
      visit: visit ?? this.visit,
      progress: progress ?? this.progress,
      rewards: rewards ?? this.rewards,
      region: region ?? this.region,
      village: village ?? this.village,
      block: block ?? this.block,
    );
  }
}
