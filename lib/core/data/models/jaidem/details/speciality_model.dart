class SpecialityModel {
  final int id;
  final String nameRu;
  final String? nameEn;
  final String? nameKg;

  const SpecialityModel({
    required this.id,
    required this.nameRu,
    this.nameEn,
    this.nameKg,
  });

  factory SpecialityModel.fromJson(Map<String, dynamic> json) {
    return SpecialityModel(
      id: json['id'] as int,
      nameRu: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      nameKg: json['nameKg'] as String?,
    );
  }

  String getLocalizedName(String locale) {
    switch (locale) {
      case 'en':
        return nameEn ?? nameRu;
      case 'ky':
        return nameKg ?? nameRu;
      default:
        return nameRu;
    }
  }

  SpecialityModel copyWith({
    int? id,
    String? nameRu,
    String? nameEn,
    String? nameKg,
  }) {
    return SpecialityModel(
      id: id ?? this.id,
      nameRu: nameRu ?? this.nameRu,
      nameEn: nameEn ?? this.nameEn,
      nameKg: nameKg ?? this.nameKg,
    );
  }
}
