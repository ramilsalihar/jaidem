class FacultyModel {
  final int id;
  final String nameRu;
  final String? nameEn;
  final String? nameKg;

  const FacultyModel({
    required this.id,
    required this.nameRu,
    this.nameEn,
    this.nameKg,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'] as int,
      nameRu: json['nameRu'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      nameKg: json['nameKg'] as String?,
    );
  }

  String getLocalizedName(String locale) {
    switch (locale) {
      case 'en':
        return nameEn?.isNotEmpty == true ? nameEn! : nameRu;
      case 'ky':
        return nameKg?.isNotEmpty == true ? nameKg! : nameRu;
      default:
        return nameRu;
    }
  }
}
