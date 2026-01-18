import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/forum/data/services/forum_firebase_service.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/domain/usecases/get_all_forums.dart';
import 'package:jaidem/features/forum/domain/usecases/get_forum_comment.dart';
import 'package:jaidem/features/forum/domain/usecases/like_post_usecase.dart';
import 'package:jaidem/features/forum/domain/usecases/post_forum_comment.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';

part 'forum_state.dart';

class ForumCubit extends Cubit<ForumState> {
  ForumCubit({
    required this.getAllForums,
    required this.getForumComment,
    required this.postForumComment,
    required this.likePostUsecase,
  }) : super(const ForumState());

  final GetAllForums getAllForums;
  final GetForumComment getForumComment;
  final PostForumComment postForumComment;
  final LikePostUsecase likePostUsecase;
  final ForumFirebaseService _firebaseService = ForumFirebaseService();

  Future<void> fetchAllForums({String? search}) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await getAllForums(search);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.toString()));
      },
      (forums) {
        emit(state.copyWith(isLoading: false, forums: forums, error: null));
      },
    );
  }

  /// Fetch comments from Firebase for a specific forum
  Future<void> fetchForumComments(int forumId) async {
    emit(state.copyWith(
      isCommentsLoading: true,
      commentsError: null,
      currentForumId: forumId,
    ));

    try {
      final comments = await _firebaseService.getComments(forumId);
      emit(state.copyWith(
        isCommentsLoading: false,
        comments: comments,
        commentsError: null,
        currentForumId: forumId,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCommentsLoading: false,
        commentsError: e.toString(),
        currentForumId: forumId,
      ));
    }
  }

  /// Submit a comment to Firebase
  Future<void> submitForumComment(CommentEntity comment) async {
    final forumId = comment.post as int;
    emit(state.copyWith(isCommentsLoading: true, commentsError: null));

    try {
      final postedComment = await _firebaseService.postComment(
        forumId,
        comment.content,
      );

      if (postedComment != null) {
        // Refresh comments after posting
        final comments = await _firebaseService.getComments(forumId);
        emit(state.copyWith(
          isCommentsLoading: false,
          comments: comments,
          lastPostedComment: postedComment,
          commentsError: null,
        ));
      } else {
        emit(state.copyWith(
          isCommentsLoading: false,
          commentsError: 'Комментарий жөнөтүлгөн жок',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isCommentsLoading: false,
        commentsError: e.toString(),
      ));
    }
  }

  /// Toggle like using Firebase
  Future<bool> toggleLike(int forumId) async {
    return await _firebaseService.toggleLike(forumId);
  }

  /// Check if user has liked a forum
  Future<bool> hasUserLiked(int forumId) async {
    return await _firebaseService.hasUserLikedForum(forumId);
  }

  /// Get likes count from Firebase
  Future<int> getLikesCount(int forumId) async {
    return await _firebaseService.getLikesCount(forumId);
  }

  /// Get like info (isLiked and count) from Firebase
  Future<Map<String, dynamic>> getLikeInfo(int forumId) async {
    return await _firebaseService.getLikeInfo(forumId);
  }

  /// Get comments count from Firebase using aggregate function
  Future<int> getCommentsCount(int forumId) async {
    return await _firebaseService.getCommentsCount(forumId);
  }

  /// Legacy method - kept for compatibility but now uses Firebase internally
  Future<void> likeForumPost(int forumId) async {
    await _firebaseService.toggleLike(forumId);
  }

  // ==================== COMMENT LIKES ====================

  /// Toggle like for a comment
  Future<bool> toggleCommentLike(int forumId, String commentId) async {
    return await _firebaseService.toggleCommentLike(forumId, commentId);
  }

  /// Get comment like info
  Future<Map<String, dynamic>> getCommentLikeInfo(int forumId, String commentId) async {
    return await _firebaseService.getCommentLikeInfo(forumId, commentId);
  }

  // ==================== COMMENT REPLIES ====================

  /// Submit a reply to a comment
  Future<void> submitReply(
    int forumId,
    String parentCommentId,
    String content,
    String parentAuthorName,
  ) async {
    emit(state.copyWith(isCommentsLoading: true, commentsError: null));

    try {
      final postedReply = await _firebaseService.postReply(
        forumId,
        parentCommentId,
        content,
        parentAuthorName,
      );

      if (postedReply != null) {
        // Refresh comments after posting reply
        final comments = await _firebaseService.getComments(forumId);
        emit(state.copyWith(
          isCommentsLoading: false,
          comments: comments,
          lastPostedComment: postedReply,
          commentsError: null,
        ));
      } else {
        emit(state.copyWith(
          isCommentsLoading: false,
          commentsError: 'Жооп жөнөтүлгөн жок',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isCommentsLoading: false,
        commentsError: e.toString(),
      ));
    }
  }

  /// Set reply target for the comment input
  void setReplyTarget(String? commentId, String? authorName) {
    emit(state.copyWith(
      replyToCommentId: commentId,
      replyToAuthorName: authorName,
    ));
  }

  /// Clear reply target
  void clearReplyTarget() {
    emit(state.copyWith(
      replyToCommentId: null,
      replyToAuthorName: null,
    ));
  }
}
