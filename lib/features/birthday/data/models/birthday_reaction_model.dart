class BirthdayReactionModel {
  final int id;
  final Map<String, dynamic>? fromUser;
  final String emoji;
  final String createdAt;

  const BirthdayReactionModel({
    required this.id,
    this.fromUser,
    required this.emoji,
    required this.createdAt,
  });

  factory BirthdayReactionModel.fromJson(Map<String, dynamic> json) {
    return BirthdayReactionModel(
      id: json['id'] ?? 0,
      fromUser: json['from_user'] as Map<String, dynamic>?,
      emoji: json['emoji'] ?? '🎉',
      createdAt: json['created_at'] ?? '',
    );
  }

  String get fromUserName => fromUser?['fullname']?.toString() ?? '';
  String get fromUserAvatar => fromUser?['avatar']?.toString() ?? '';
}

class BirthdayReactionsResponse {
  final int count;
  final List<BirthdayReactionModel> reactions;

  const BirthdayReactionsResponse({
    required this.count,
    required this.reactions,
  });

  factory BirthdayReactionsResponse.fromJson(Map<String, dynamic> json) {
    return BirthdayReactionsResponse(
      count: json['count'] ?? 0,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) =>
                  BirthdayReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
