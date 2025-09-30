class VillageModel {
  final int id;
  final String name;
  final String? nameRu;
  final String? nameKg;
  final int? region;

  const VillageModel({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameKg,
    this.region,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameRu: json['nameRu'] as String?,
      nameKg: json['nameKg'] as String?,
      region: json['region'] as int?,
    );
  }

  VillageModel copyWith({
    int? id,
    String? name,
    String? nameRu,
    String? nameKg,
    int? region,
  }) {
    return VillageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameKg: nameKg ?? this.nameKg,
      region: region ?? this.region,
    );
  }
}
