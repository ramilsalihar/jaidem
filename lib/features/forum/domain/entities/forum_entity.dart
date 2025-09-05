class ForumEntity {
  final int id;
  final dynamic author;
  final String title;
  final String content;
  final String createdAt;

  ForumEntity({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}
