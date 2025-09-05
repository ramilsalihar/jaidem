class CommentEntity {
  final int id;
  final dynamic author;
  final dynamic post;
  final String content;
  final String createdAt;

  CommentEntity({
    required this.id,
    required this.author,
    required this.post,
    required this.content,
    required this.createdAt,
  });
}
