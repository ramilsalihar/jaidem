class BirthdayUserModel {
  final int id;
  final String? fullname;
  final String? avatar;
  final Map<String, dynamic>? flow;
  final String? generation;
  final int reactionCount;
  final bool hasReacted;

  const BirthdayUserModel({
    required this.id,
    this.fullname,
    this.avatar,
    this.flow,
    this.generation,
    required this.reactionCount,
    required this.hasReacted,
  });

  factory BirthdayUserModel.fromJson(Map<String, dynamic> json) {
    return BirthdayUserModel(
      id: json['id'] ?? 0,
      fullname: json['fullname'] as String?,
      avatar: json['avatar'] as String?,
      flow: json['flow'] as Map<String, dynamic>?,
      generation: json['generation'] as String?,
      reactionCount: json['reaction_count'] ?? 0,
      hasReacted: json['has_reacted'] ?? false,
    );
  }

  String get flowName {
    if (flow == null) return '';
    return flow!['name']?.toString() ?? '';
  }
}
