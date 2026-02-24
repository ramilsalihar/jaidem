class SpecialityModel {
  final int id;
  final String name;
  final String? nameEn;
  final String? nameKg;

  const SpecialityModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameKg,
  });

  factory SpecialityModel.fromJson(Map<String, dynamic> json) {
    return SpecialityModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      nameKg: json['nameKg'] as String?,
    );
  }

  String getLocalizedName(String locale) {
    switch (locale) {
      case 'en':
        return nameEn?.isNotEmpty == true ? nameEn! : name;
      case 'ky':
        return nameKg?.isNotEmpty == true ? nameKg! : name;
      default:
        return name;
    }
  }

  SpecialityModel copyWith({
    int? id,
    String? name,
    String? nameEn,
    String? nameKg,
  }) {
    return SpecialityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nameKg: nameKg ?? this.nameKg,
    );
  }
}
