class RegionModel {
  final int id;
  final String name;
  final String? nameRu;
  final String? nameKg;
  final int? state;

  const RegionModel({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameKg,
    this.state,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameRu: json['nameRu'] as String?,
      nameKg: json['nameKg'] as String?,
      state: json['state'] as int?,
    );
  }

  RegionModel copyWith({
    int? id,
    String? name,
    String? nameRu,
    String? nameKg,
    int? state,
  }) {
    return RegionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameKg: nameKg ?? this.nameKg,
      state: state ?? this.state,
    );
  }
}
