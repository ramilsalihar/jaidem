class CategoryModel {
  final int id;
  final String? nameKg;
  final String? nameRu;
  final String? nameEn;

  const CategoryModel({
    required this.id,
    this.nameKg,
    this.nameRu,
    this.nameEn,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      nameKg: json['nameKg'] as String?,
      nameRu: json['nameRu'] as String?,
      nameEn: json['nameEn'] as String?,
    );
  }

  String getLocalizedName(String locale) {
    switch (locale) {
      case 'ky':
        return nameKg ?? nameRu ?? nameEn ?? '';
      case 'ru':
        return nameRu ?? nameEn ?? '';
      default:
        return nameEn ?? '';
    }
  }
}
