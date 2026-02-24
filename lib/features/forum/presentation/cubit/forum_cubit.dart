import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:jaidem/features/forum/data/services/forum_firebase_service.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/domain/usecases/get_all_forums.dart';
import 'package:jaidem/features/forum/domain/usecases/get_forum_comment.dart';
import 'package:jaidem/features/forum/domain/usecases/like_post_usecase.dart';
import 'package:jaidem/features/forum/domain/usecases/post_forum_comment.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:jaidem/features/forum/data/mappers/forum_mapper.dart';

part 'forum_state.dart';

class ForumCubit extends Cubit<ForumState> {
  ForumCubit({
    required this.getAllForums,
    required this.getForumComment,
    required this.postForumComment,
    required this.likePostUsecase,
    required this.forumRemoteDataSource,
  }) : super(const ForumState());

  final GetAllForums getAllForums;
  final GetForumComment getForumComment;
  final PostForumComment postForumComment;
  final LikePostUsecase likePostUsecase;
  final ForumRemoteDataSource forumRemoteDataSource;
  final ForumFirebaseService _firebaseService = ForumFirebaseService();

  Future<void> fetchAllForums({String? search, int? authorId}) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null));
    final result = await getAllForums(search, authorId: authorId);
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) emit(state.copyWith(isLoading: false, error: failure.toString()));
      },
      (forums) async {
        if (isClosed) return;
        // Filter out posts from blocked users
        try {
          final blockedIds = await _firebaseService.getBlockedUserIds();
          if (isClosed) return;
          if (blockedIds.isNotEmpty) {
            final filtered = forums
                .where((f) => f.author?.id == null || !blockedIds.contains(f.author!.id.toString()))
                .toList();
            emit(state.copyWith(isLoading: false, forums: filtered, error: null));
          } else {
            emit(state.copyWith(isLoading: false, forums: forums, error: null));
          }
        } catch (_) {
          if (!isClosed) emit(state.copyWith(isLoading: false, forums: forums, error: null));
        }
      },
    );
  }

  /// Fetch a single forum by ID (for deep linking)
  Future<void> fetchForumById(int forumId) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, error: null, selectedForum: null));
    final result = await forumRemoteDataSource.fetchForumById(forumId);
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) emit(state.copyWith(isLoading: false, error: failure));
      },
      (forumModel) {
        if (!isClosed) {
          final forumEntity = ForumMapper.toEntity(forumModel);
          emit(state.copyWith(isLoading: false, selectedForum: forumEntity, error: null));
        }
      },
    );
  }

  /// Fetch comments from Firebase for a specific forum
  Future<void> fetchForumComments(int forumId) async {
    if (isClosed) return;
    emit(state.copyWith(
      isCommentsLoading: true,
      commentsError: null,
      currentForumId: forumId,
    ));

    try {
      final comments = await _firebaseService.getComments(forumId);
      if (isClosed) return;
      emit(state.copyWith(
        isCommentsLoading: false,
        comments: comments,
        commentsError: null,
        currentForumId: forumId,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isCommentsLoading: false,
        commentsError: e.toString(),
        currentForumId: forumId,
      ));
    }
  }

  /// Submit a comment to Firebase
  Future<void> submitForumComment(CommentEntity comment) async {
    if (isClosed) return;
    final forumId = comment.post as int;
    emit(state.copyWith(isCommentsLoading: true, commentsError: null));

    try {
      final postedComment = await _firebaseService.postComment(
        forumId,
        comment.content,
      );
      if (isClosed) return;

      if (postedComment != null) {
        // Refresh comments after posting
        final comments = await _firebaseService.getComments(forumId);
        if (isClosed) return;
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
      if (isClosed) return;
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
    if (isClosed) return;
    emit(state.copyWith(isCommentsLoading: true, commentsError: null));

    try {
      final postedReply = await _firebaseService.postReply(
        forumId,
        parentCommentId,
        content,
        parentAuthorName,
      );
      if (isClosed) return;

      if (postedReply != null) {
        // Refresh comments after posting reply
        final comments = await _firebaseService.getComments(forumId);
        if (isClosed) return;
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
      if (isClosed) return;
      emit(state.copyWith(
        isCommentsLoading: false,
        commentsError: e.toString(),
      ));
    }
  }

  /// Set reply target for the comment input
  void setReplyTarget(String? commentId, String? authorName) {
    if (isClosed) return;
    emit(state.copyWith(
      replyToCommentId: commentId,
      replyToAuthorName: authorName,
    ));
  }

  /// Clear reply target
  void clearReplyTarget() {
    if (isClosed) return;
    emit(state.copyWith(
      replyToCommentId: null,
      replyToAuthorName: null,
    ));
  }

  // ==================== CONTENT MODERATION ====================

  /// Report a post for inappropriate content
  Future<void> reportPost(int forumId, String reason, {int? authorId, String? authorName}) async {
    try {
      await _firebaseService.reportPost(forumId, reason, authorId: authorId, authorName: authorName);
    } catch (e) {
      debugPrint('Report error: $e');
    }
  }

  /// Report a comment for inappropriate content
  Future<void> reportComment({
    required int forumId,
    required String commentId,
    required String reason,
    String? userId,
    String? userName,
  }) async {
    try {
      await _firebaseService.reportComment(
        forumId: forumId,
        commentId: commentId,
        reason: reason,
        reportedUserId: userId,
        reportedUserName: userName,
      );
    } catch (e) {
      debugPrint('Report comment error: $e');
    }
  }

  /// Block a user and remove their content from current view
  Future<void> blockUser(int userId, {String? userName}) async {
    try {
      await _firebaseService.blockUser(userId, blockedUserName: userName);
      if (isClosed) return;

      // Remove blocked user's posts from current view
      final filteredForums = state.forums
          .where((forum) => forum.author?.id != userId)
          .toList();

      // Also filter blocked user's comments
      final filteredComments = state.comments
          .where((comment) => _getCommentAuthorId(comment) != userId.toString())
          .map((comment) => comment.copyWith(
                replies: comment.replies
                    .where((reply) => _getCommentAuthorId(reply) != userId.toString())
                    .toList(),
              ))
          .toList();

      emit(state.copyWith(forums: filteredForums, comments: filteredComments));
    } catch (e) {
      debugPrint('Block error: $e');
    }
  }

  String? _getCommentAuthorId(CommentEntity comment) {
    if (comment.author is Map<String, dynamic>) {
      return (comment.author as Map<String, dynamic>)['id']?.toString();
    }
    return null;
  }
}
