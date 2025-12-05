class StateModel {
  final int id;
  final String name;
  final String? nameRu;
  final String? nameKg;

  const StateModel({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameKg,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameRu: json['nameRu'] as String,
      nameKg: json['nameKg'] as String,
    );
  }

  StateModel copyWith({
    int? id,
    String? name,
    String? nameRu,
    String? nameKg,
  }) {
    return StateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameKg: nameKg ?? this.nameKg,
    );
  }

  factory StateModel.empty() {
    return StateModel(
      id: 0,
      name: '',
      nameRu: '',
      nameKg: '',
    );
  }
}
