class OtherSchoolModel {
  final int id;
  final String name;
  final String description;
  final String photo;
  final String? startDate;
  final String? endDate;

  const OtherSchoolModel({
    required this.id,
    required this.name,
    this.description = '',
    this.photo = '',
    this.startDate,
    this.endDate,
  });

  factory OtherSchoolModel.fromJson(Map<String, dynamic> json) {
    return OtherSchoolModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      startDate: json['dateStart'] as String?,
      endDate: json['dateEnd'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'photo': photo,
      if (startDate != null) 'dateStart': startDate,
      if (endDate != null) 'dateEnd': endDate,
    };
  }

  OtherSchoolModel copyWith({
    int? id,
    String? name,
    String? description,
    String? photo,
    String? startDate,
    String? endDate,
  }) {
    return OtherSchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
