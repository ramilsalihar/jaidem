import 'package:jaidem/features/forum/data/models/author_model.dart';

class ForumModel {
  final int id;
  final AuthorModel? author;
  final String? title;
  final String? content;
  final String? createdAt;
  final String? photo;
  final int? likesCount;
  final List<String>? likedUsers;
  final bool isLikedByCurrentUser;

  ForumModel({
    required this.id,
    this.author,
    this.title,
    this.content,
    this.createdAt,
    this.photo,
    this.likesCount,
    this.likedUsers,
    this.isLikedByCurrentUser = false,
  });

  ForumModel copyWith({
    int? id,
    AuthorModel? author,
    String? title,
    String? content,
    String? createdAt,
    String? photo,
    int? likesCount,
    List<String>? likedUsers,
    bool? isLikedByCurrentUser,
  }) {
    return ForumModel(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      photo: photo ?? this.photo,
      likesCount: likesCount ?? this.likesCount,
      likedUsers: likedUsers ?? this.likedUsers,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}
