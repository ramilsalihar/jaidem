import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForumFirebaseService {
  static final ForumFirebaseService _instance = ForumFirebaseService._internal();
  factory ForumFirebaseService() => _instance;
  ForumFirebaseService._internal();

  FirebaseFirestore get _firestore => sl<FirebaseFirestore>();
  SharedPreferences get _prefs => sl<SharedPreferences>();

  String? get _userId => _prefs.getString(AppConstants.userId);
  String? get _username => _prefs.getString(AppConstants.userLogin);
  String? get _userFullname => _prefs.getString(AppConstants.userFullname);
  String? get _userAvatar => _prefs.getString(AppConstants.userAvatar);

  // ==================== LIKES ====================

  /// Check if the current user has liked a forum post
  Future<bool> hasUserLikedForum(int forumId) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return false;

    try {
      final doc = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('likes')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  /// Toggle like for a forum post
  /// Returns true if liked, false if unliked
  Future<bool> toggleLike(int forumId) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return false;

    try {
      final likeRef = _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('likes')
          .doc(userId);

      final doc = await likeRef.get();

      if (doc.exists) {
        // Unlike - remove the document
        await likeRef.delete();
        return false;
      } else {
        // Like - create the document
        await likeRef.set({
          'userId': userId,
          'dateTime': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Get the total likes count for a forum post
  Future<int> getLikesCount(int forumId) async {
    try {
      final snapshot = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('likes')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get like status and count for a forum post
  Future<Map<String, dynamic>> getLikeInfo(int forumId) async {
    final isLiked = await hasUserLikedForum(forumId);
    final count = await getLikesCount(forumId);
    return {
      'isLiked': isLiked,
      'count': count,
    };
  }

  // ==================== COMMENTS ====================

  /// Get comments for a forum post
  Stream<List<CommentEntity>> getCommentsStream(int forumId) {
    return _firestore
        .collection('forums')
        .doc(forumId.toString())
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CommentEntity(
          id: doc.id.hashCode,
          author: data['author'],
          post: forumId,
          content: data['content'] ?? '',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        );
      }).toList();
    });
  }

  /// Get comments for a forum post (one-time fetch)
  Future<List<CommentEntity>> getComments(int forumId) async {
    try {
      final blockedUserIds = await getBlockedUserIds();

      final snapshot = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      final userId = _userId;
      final List<CommentEntity> allComments = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Skip comments from blocked users
        final authorId = (data['author'] as Map<String, dynamic>?)?['id']?.toString();
        if (authorId != null && blockedUserIds.contains(authorId)) {
          continue;
        }

        // Get like info for this comment
        int likesCount = 0;
        bool isLiked = false;

        try {
          final likesSnapshot = await doc.reference.collection('likes').count().get();
          likesCount = likesSnapshot.count ?? 0;

          if (userId != null && userId.isNotEmpty) {
            final userLikeDoc = await doc.reference.collection('likes').doc(userId).get();
            isLiked = userLikeDoc.exists;
          }
        } catch (_) {}

        allComments.add(CommentEntity(
          id: doc.id.hashCode,
          documentId: doc.id,
          author: data['author'],
          post: forumId,
          content: data['content'] ?? '',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          parentId: data['parentId'],
          parentAuthorName: data['parentAuthorName'],
          likesCount: likesCount,
          isLikedByCurrentUser: isLiked,
        ));
      }

      // Separate parent comments and replies
      final parentComments = allComments.where((c) => c.parentId == null).toList();
      final replies = allComments.where((c) => c.parentId != null).toList();

      // Attach replies to their parent comments (already filtered by blocked users above)
      return parentComments.map((parent) {
        final parentReplies = replies.where((r) => r.parentId == parent.documentId).toList();
        return parent.copyWith(replies: parentReplies);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Post a comment to a forum
  Future<CommentEntity?> postComment(int forumId, String content) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return null;

    try {
      // Use fullname if available, fallback to username, then default
      final displayName = _userFullname ?? _username ?? 'Белгисиз';

      final author = {
        'id': userId,
        'fullname': displayName,
        'avatar': _userAvatar,
      };

      final docRef = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .add({
        'author': author,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      return CommentEntity(
        id: docRef.id.hashCode,
        documentId: docRef.id,
        author: author,
        post: forumId,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(int forumId, String commentId) async {
    try {
      await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .doc(commentId)
          .delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get comments count for a forum post
  Future<int> getCommentsCount(int forumId) async {
    try {
      final snapshot = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ==================== COMMENT LIKES ====================

  /// Toggle like for a comment
  /// Returns true if liked, false if unliked
  Future<bool> toggleCommentLike(int forumId, String commentId) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return false;

    try {
      final likeRef = _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(userId);

      final doc = await likeRef.get();

      if (doc.exists) {
        await likeRef.delete();
        return false;
      } else {
        await likeRef.set({
          'userId': userId,
          'dateTime': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Check if user has liked a comment
  Future<bool> hasUserLikedComment(int forumId, String commentId) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return false;

    try {
      final doc = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  /// Get comment likes count
  Future<int> getCommentLikesCount(int forumId, String commentId) async {
    try {
      final snapshot = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get comment like info (isLiked and count)
  Future<Map<String, dynamic>> getCommentLikeInfo(int forumId, String commentId) async {
    final isLiked = await hasUserLikedComment(forumId, commentId);
    final count = await getCommentLikesCount(forumId, commentId);
    return {
      'isLiked': isLiked,
      'count': count,
    };
  }

  // ==================== COMMENT REPLIES ====================

  /// Post a reply to a comment
  Future<CommentEntity?> postReply(
    int forumId,
    String parentCommentId,
    String content,
    String parentAuthorName,
  ) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return null;

    try {
      final displayName = _userFullname ?? _username ?? 'Белгисиз';

      final author = {
        'id': userId,
        'fullname': displayName,
        'avatar': _userAvatar,
      };

      final docRef = await _firestore
          .collection('forums')
          .doc(forumId.toString())
          .collection('comments')
          .add({
        'author': author,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'parentId': parentCommentId,
        'parentAuthorName': parentAuthorName,
      });

      return CommentEntity(
        id: docRef.id.hashCode,
        documentId: docRef.id,
        author: author,
        post: forumId,
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        parentId: parentCommentId,
        parentAuthorName: parentAuthorName,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== CONTENT MODERATION ====================

  /// Report a post for inappropriate content
  Future<void> reportPost(int forumId, String reason, {int? authorId, String? authorName}) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore.collection('reports').add({
        'type': 'post',
        'forumId': forumId,
        'reason': reason,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'reportedUserId': authorId?.toString(),
        'reportedUserName': authorName,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'requiresAdminAction': true,
      });

      await _firestore.collection('admin_notifications').add({
        'type': 'content_reported',
        'contentType': 'post',
        'forumId': forumId,
        'reason': reason,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (_) {}
  }

  /// Report a comment for inappropriate content
  Future<void> reportComment({
    required int forumId,
    required String commentId,
    required String reason,
    String? reportedUserId,
    String? reportedUserName,
  }) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore.collection('reports').add({
        'type': 'comment',
        'forumId': forumId,
        'commentId': commentId,
        'reason': reason,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'reportedUserId': reportedUserId,
        'reportedUserName': reportedUserName,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'requiresAdminAction': true,
      });

      await _firestore.collection('admin_notifications').add({
        'type': 'content_reported',
        'contentType': 'comment',
        'forumId': forumId,
        'commentId': commentId,
        'reason': reason,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (_) {}
  }

  /// Report a user profile for inappropriate content
  Future<void> reportUser({
    required int reportedUserId,
    required String reason,
    String? reportedUserName,
  }) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore.collection('reports').add({
        'type': 'user',
        'reportedUserId': reportedUserId.toString(),
        'reportedUserName': reportedUserName,
        'reason': reason,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'requiresAdminAction': true,
      });

      await _firestore.collection('admin_notifications').add({
        'type': 'user_reported',
        'reportedUserId': reportedUserId.toString(),
        'reportedUserName': reportedUserName,
        'reason': reason,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (_) {}
  }

  /// Block a user with developer notification
  Future<void> blockUser(int blockedUserId, {String? blockedUserName}) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('blocked_users')
          .doc(blockedUserId.toString())
          .set({
        'blockedUserId': blockedUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // Notify developer
      await _firestore.collection('reports').add({
        'type': 'user_block',
        'blockedUserId': blockedUserId,
        'blockedUserName': blockedUserName,
        'blockedByUserId': userId,
        'blockedByUserName': _userFullname,
        'reason': 'user_blocked_by_another_user',
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'requiresAdminAction': true,
      });

      await _firestore.collection('admin_notifications').add({
        'type': 'user_blocked',
        'blockedUserId': blockedUserId,
        'blockedUserName': blockedUserName,
        'reportedBy': userId,
        'reportedByName': _userFullname,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (_) {}
  }

  /// Get set of blocked user IDs for the current user
  Future<Set<String>> getBlockedUserIds() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return {};

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('blocked_users')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(int checkUserId) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('blocked_users')
          .doc(checkUserId.toString())
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  /// Unblock a user
  Future<void> unblockUser(int blockedUserId) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('blocked_users')
          .doc(blockedUserId.toString())
          .delete();
    } catch (_) {
      // Silently handle error
    }
  }
}
