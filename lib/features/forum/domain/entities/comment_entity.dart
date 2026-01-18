class CommentEntity {
  final int id;
  final String? documentId;
  final dynamic author;
  final dynamic post;
  final String content;
  final String createdAt;
  final String? parentId;
  final String? parentAuthorName;
  final int likesCount;
  final bool isLikedByCurrentUser;
  final List<CommentEntity> replies;

  CommentEntity({
    required this.id,
    this.documentId,
    required this.author,
    required this.post,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.parentAuthorName,
    this.likesCount = 0,
    this.isLikedByCurrentUser = false,
    this.replies = const [],
  });

  CommentEntity copyWith({
    int? id,
    String? documentId,
    dynamic author,
    dynamic post,
    String? content,
    String? createdAt,
    String? parentId,
    String? parentAuthorName,
    int? likesCount,
    bool? isLikedByCurrentUser,
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      author: author ?? this.author,
      post: post ?? this.post,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      parentAuthorName: parentAuthorName ?? this.parentAuthorName,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      replies: replies ?? this.replies,
    );
  }
}
