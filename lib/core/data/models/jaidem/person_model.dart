import 'package:jaidem/core/data/models/jaidem/details/additional_education_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/category_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/other_school_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/region_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/speciality_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/state_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/university_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/village_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/success_history_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/work_place_model.dart';

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
  final UniversityModel? univer;
  final SpecialityModel? spec;
  final String? birthday;
  final bool isAdvisor;
  final String? linkToReserve;
  final bool noUniversity;
  final String? univerStartDate;
  final String? univerEndDate;
  final List<OtherSchoolModel>? otherSchools;
  final List<WorkPlaceModel>? workPlaces;
  final List<SuccessHistoryModel>? successHist;
  final List<AdditionalEducationModel>? additionalEducations;
  final List<String>? positionsInJaidem;
  final String? inWhatIcanHelp;
  final String? whatINeed;
  final String? openTo;
  final String? vkladToJaidem;
  final String? telegram;
  final List<String>? tags;
  final CategoryModel? category;

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
    this.univer,
    this.spec,
    this.birthday,
    this.isAdvisor = false,
    this.linkToReserve,
    this.noUniversity = false,
    this.univerStartDate,
    this.univerEndDate,
    this.otherSchools,
    this.workPlaces,
    this.successHist,
    this.additionalEducations,
    this.positionsInJaidem,
    this.inWhatIcanHelp,
    this.whatINeed,
    this.openTo,
    this.vkladToJaidem,
    this.telegram,
    this.tags,
    this.category,
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
      univer: json['univer'] != null
          ? UniversityModel.fromJson(json['univer'] as Map<String, dynamic>)
          : null,
      spec: json['spec'] != null
          ? SpecialityModel.fromJson(json['spec'] as Map<String, dynamic>)
          : null,
      birthday: json['birthday'] as String?,
      isAdvisor: json['isAdvisor'] as bool? ?? false,
      linkToReserve: json['linkToReserve'] as String?,
      noUniversity: json['noUniversity'] as bool? ?? false,
      univerStartDate: json['univerStartDate'] as String?,
      univerEndDate: json['univerEndDate'] as String?,
      otherSchools: (json['otherSchools'] as List?)
          ?.map((e) => OtherSchoolModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      workPlaces: (json['workPlaces'] as List?)
          ?.map((e) => WorkPlaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      successHist: (json['successHist'] as List?)
          ?.map((e) => SuccessHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      additionalEducations: (json['additionalEducations'] as List?)
          ?.map((e) => AdditionalEducationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      positionsInJaidem: (json['positionsInJaidem'] as List?)
          ?.map((e) => e as String)
          .toList(),
      inWhatIcanHelp: json['inWhatIcanHelp'] as String?,
      whatINeed: json['whatINeed'] as String?,
      openTo: json['openTo'] as String?,
      vkladToJaidem: json['vkladToJaidem'] as String?,
      telegram: json['telegram'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
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
    UniversityModel? univer,
    SpecialityModel? spec,
    String? birthday,
    bool? isAdvisor,
    String? linkToReserve,
    bool? noUniversity,
    String? univerStartDate,
    String? univerEndDate,
    List<OtherSchoolModel>? otherSchools,
    List<WorkPlaceModel>? workPlaces,
    List<SuccessHistoryModel>? successHist,
    List<AdditionalEducationModel>? additionalEducations,
    List<String>? positionsInJaidem,
    String? inWhatIcanHelp,
    String? whatINeed,
    String? openTo,
    String? vkladToJaidem,
    String? telegram,
    List<String>? tags,
    CategoryModel? category,
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
      univer: univer ?? this.univer,
      spec: spec ?? this.spec,
      birthday: birthday ?? this.birthday,
      isAdvisor: isAdvisor ?? this.isAdvisor,
      linkToReserve: linkToReserve ?? this.linkToReserve,
      noUniversity: noUniversity ?? this.noUniversity,
      univerStartDate: univerStartDate ?? this.univerStartDate,
      univerEndDate: univerEndDate ?? this.univerEndDate,
      otherSchools: otherSchools ?? this.otherSchools,
      workPlaces: workPlaces ?? this.workPlaces,
      successHist: successHist ?? this.successHist,
      additionalEducations: additionalEducations ?? this.additionalEducations,
      positionsInJaidem: positionsInJaidem ?? this.positionsInJaidem,
      inWhatIcanHelp: inWhatIcanHelp ?? this.inWhatIcanHelp,
      whatINeed: whatINeed ?? this.whatINeed,
      openTo: openTo ?? this.openTo,
      vkladToJaidem: vkladToJaidem ?? this.vkladToJaidem,
      telegram: telegram ?? this.telegram,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  /// Calculate age from birthday string (YYYY-MM-DD format).
  /// Returns null if birthday is null or empty.
  int? get calculatedAge {
    if (birthday == null || birthday!.isEmpty) return null;
    final birthDate = DateTime.tryParse(birthday!);
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age > 0 ? age : null;
  }
}
