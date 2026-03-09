class WorkPlaceModel {
  final int id;
  final String name;
  final String position;
  final String description;
  final String photo;
  final String? startDate;
  final String? endDate;

  const WorkPlaceModel({
    required this.id,
    required this.name,
    this.position = '',
    this.description = '',
    this.photo = '',
    this.startDate,
    this.endDate,
  });

  factory WorkPlaceModel.fromJson(Map<String, dynamic> json) {
    return WorkPlaceModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      startDate: json['dateStart'] as String?,
      endDate: json['dateEnd'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'description': description,
      'photo': photo,
      if (startDate != null) 'dateStart': startDate,
      if (endDate != null) 'dateEnd': endDate,
    };
  }

  WorkPlaceModel copyWith({
    int? id,
    String? name,
    String? position,
    String? description,
    String? photo,
    String? startDate,
    String? endDate,
  }) {
    return WorkPlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
