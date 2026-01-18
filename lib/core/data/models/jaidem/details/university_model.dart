class UniversityModel {
  final int id;
  final String name;
  final String? nameRu;
  final String? nameKg;

  const UniversityModel({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameKg,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameRu: json['name_ru'] as String?,
      nameKg: json['name_kg'] as String?,
    );
  }

  String getLocalizedName(String locale) {
    switch (locale) {
      case 'ru':
        return nameRu ?? name;
      case 'ky':
        return nameKg ?? nameRu ?? name;
      default:
        return name;
    }
  }

  UniversityModel copyWith({
    int? id,
    String? name,
    String? nameRu,
    String? nameKg,
  }) {
    return UniversityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameKg: nameKg ?? this.nameKg,
    );
  }
}
