import 'package:jaidem/features/forum/domain/entities/author_entity.dart';

class ForumEntity {
  final int id;
  final AuthorEntity? author;
  final String title;
  final String content;
  final String? createdAt;
  final String? photo;
  final int? likesCount;
  final List<String>? likedUsers;

  ForumEntity({
    required this.id,
    this.author,
    required this.title,
    required this.content,
    this.createdAt,
    this.photo,
    this.likesCount,
    this.likedUsers,
  });
}
