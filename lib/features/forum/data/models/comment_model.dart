class CommentModel {
  final int id;
  final dynamic author;
  final dynamic post;
  final String content;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.author,
    required this.post,
    required this.content,
    required this.createdAt,
  });

  CommentModel copyWith({
    int? id,
    dynamic author,
    dynamic post,
    String? content,
    String? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      author: author ?? this.author,
      post: post ?? this.post,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
