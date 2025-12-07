class Division {
  final int id;
  final String name;
  final String nameEn;
  final String nameKg;

  Division({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameKg,
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      nameKg: json['nameKg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'nameKg': nameKg,
    };
  }
}
