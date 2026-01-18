import 'package:jaidem/core/data/models/jaidem/details/state_model.dart';

class RegionModel {
  final int id;
  final String nameEn;
  final String? nameRu;
  final String? nameKg;
  final StateModel? stateModel;

  const RegionModel({
    required this.id,
    required this.nameEn,
    this.nameRu,
    this.nameKg,
    this.stateModel,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as int,
      nameEn: json['name'] as String,
      nameRu: json['nameRu'] as String?,
      nameKg: json['nameKg'] as String?,
      stateModel: json['state'] != null
          ? (json['state'] is Map<String, dynamic>
              ? StateModel.fromJson(json['state'] as Map<String, dynamic>)
              : null)
          : null,
    );
  }

  String getLocalizedName(String locale) {
    switch (locale) {
      case 'ru':
        return nameRu ?? nameEn;
      case 'ky':
        return nameKg ?? nameRu ?? nameEn;
      default:
        return nameEn;
    }
  }

  RegionModel copyWith({
    int? id,
    String? nameEn,
    String? nameRu,
    String? nameKg,
    StateModel? stateModel,
  }) {
    return RegionModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameRu: nameRu ?? this.nameRu,
      nameKg: nameKg ?? this.nameKg,
      stateModel: stateModel ?? this.stateModel,
    );
  }
}
