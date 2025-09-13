import 'package:jaidem/features/forum/data/models/author_model.dart';

class ForumModel {
  final int id;
  final AuthorModel? author;
  final String title;
  final String content;
  final String? createdAt;
  final String? photo;
  final int? likesCount;
  final List<String>? likedUsers;

  ForumModel({
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
