part of 'forum_cubit.dart';


class ForumState extends Equatable {
  final List<ForumEntity> forums;
  final List<CommentEntity> comments;
  final bool isLoading;
  final bool isCommentsLoading;
  final String? error;
  final String? commentsError;
  final CommentEntity? lastPostedComment;

  const ForumState({
    this.forums = const [],
    this.comments = const [],
    this.isLoading = false,
    this.isCommentsLoading = false,
    this.error,
    this.commentsError,
    this.lastPostedComment,
  });

  ForumState copyWith({
    List<ForumEntity>? forums,
    List<CommentEntity>? comments,
    bool? isLoading,
    bool? isCommentsLoading,
    String? error,
    String? commentsError,
    CommentEntity? lastPostedComment,
  }) {
    return ForumState(
      forums: forums ?? this.forums,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isCommentsLoading: isCommentsLoading ?? this.isCommentsLoading,
      error: error,
      commentsError: commentsError,
      lastPostedComment: lastPostedComment,
    );
  }

  @override
  List<Object?> get props => [forums, comments, isLoading, isCommentsLoading, error, commentsError, lastPostedComment];
}
