class FlowModel {
  final int id;
  final String name;
  final String description;
  final int year;

  const FlowModel({
    required this.id,
    required this.name,
    required this.description,
    required this.year,
  });

  factory FlowModel.fromJson(Map<String, dynamic> json) {
    return FlowModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      year: json['year'] as int,
    );
  }

  FlowModel copyWith({
    int? id,
    String? name,
    String? description,
    int? year,
  }) {
    return FlowModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      year: year ?? this.year,
    );
  }

  factory FlowModel.empty() {
    return FlowModel(
      id: 0,
      name: '',
      description: '',
      year: 0,
    );
  }
}
