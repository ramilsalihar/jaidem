class SuccessHistoryModel {
  final int id;
  final String name;
  final String description;
  final DateTime? dateCreated;

  const SuccessHistoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.dateCreated,
  });

  factory SuccessHistoryModel.fromJson(Map<String, dynamic> json) {
    return SuccessHistoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateCreated: json['dateCreated'] != null
          ? DateTime.tryParse(json['dateCreated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  SuccessHistoryModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? dateCreated,
  }) {
    return SuccessHistoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
