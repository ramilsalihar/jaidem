class AdditionalEducationModel {
  final int id;
  final String title;
  final String description;
  final String? dateStart;
  final String? dateEnd;
  final DateTime? dateCreated;

  const AdditionalEducationModel({
    required this.id,
    required this.title,
    this.description = '',
    this.dateStart,
    this.dateEnd,
    this.dateCreated,
  });

  factory AdditionalEducationModel.fromJson(Map<String, dynamic> json) {
    return AdditionalEducationModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateStart: json['dateStart'] as String?,
      dateEnd: json['dateEnd'] as String?,
      dateCreated: json['dateCreated'] != null
          ? DateTime.tryParse(json['dateCreated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (dateStart != null) 'dateStart': dateStart,
      if (dateEnd != null) 'dateEnd': dateEnd,
    };
  }

  AdditionalEducationModel copyWith({
    int? id,
    String? title,
    String? description,
    String? dateStart,
    String? dateEnd,
    DateTime? dateCreated,
  }) {
    return AdditionalEducationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
