class StoryModel {
  final int id;
  final String photo;
  final DateTime createdAt;

  const StoryModel({
    required this.id,
    required this.photo,
    required this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      // id is load-bearing; a story without one is unusable, so throw on missing/wrong type.
      id: json['id'] as int,
      photo: (json['photo'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          // Feed is sorted newest-first; defaulting to "now" would float a broken story to top
          // and disguise a backend contract violation. Epoch sorts it to the bottom where it's visible as wrong.
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class StoryAuthorModel {
  final int id;
  final String? fullname;
  final String? avatar;
  final bool isAdvisor;

  const StoryAuthorModel({
    required this.id,
    this.fullname,
    this.avatar,
    required this.isAdvisor,
  });

  factory StoryAuthorModel.fromJson(Map<String, dynamic> json) {
    return StoryAuthorModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String?,
      avatar: json['avatar'] as String?,
      isAdvisor: (json['isAdvisor'] as bool?) ?? false,
    );
  }
}

class StoryGroupModel {
  final StoryAuthorModel author;
  final List<StoryModel> stories;

  const StoryGroupModel({required this.author, required this.stories});

  factory StoryGroupModel.fromJson(Map<String, dynamic> json) {
    return StoryGroupModel(
      author: StoryAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      stories: ((json['stories'] as List<dynamic>?) ?? const [])
          .map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
