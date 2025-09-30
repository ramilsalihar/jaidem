import 'package:jaidem/core/data/models/jaidem/person_model.dart';

extension PersonModelMapper on PersonModel {
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (fullname != null) data['fullname'] = fullname;
    if (avatar != null) data['avatar'] = avatar;
    if (phone != null) data['phone'] = phone;
    data['age'] = age;
    if (university != null) data['university'] = university;
    data['login'] = login;
    // password not in model, but you may inject it separately if needed
    data['course_year'] = courseYear;
    if (speciality != null) data['speciality'] = speciality;
    if (email != null) data['email'] = email;
    if (socialMedias != null) data['social_medias'] = socialMedias;
    if (interest != null) data['interest'] = interest;
    if (skills != null) data['skills'] = skills;
    data['flow'] = flow.id;
    if (generation != null) data['generation'] = generation;
    data['state'] = state.id;
    if (aboutMe != null) data['aboutMe'] = aboutMe;
    data['is_active'] = isActive;
    data['activity'] = activity;
    data['visit'] = visit;
    data['progress'] = progress;
    if (rewards != null) data['rewards'] = rewards;
    data['region'] = region.id;
    data['village'] = village.id;
    data['block'] = block;

    return data;
  }
}
