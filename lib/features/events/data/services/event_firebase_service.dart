import 'package:cloud_firestore/cloud_firestore.dart';

class EventFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ LIKES ============

  /// Get like count for an event using aggregate query
  Future<int> getLikeCount(int eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('likes')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if user has liked an event
  Future<bool> hasUserLiked(int eventId, String userId) async {
    try {
      final doc = await _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('likes')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Toggle like for an event
  Future<bool> toggleLike(int eventId, String userId) async {
    try {
      final likeRef = _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('likes')
          .doc(userId);

      final doc = await likeRef.get();

      if (doc.exists) {
        // Unlike
        await likeRef.delete();
        return false;
      } else {
        // Like
        await likeRef.set({
          'userId': userId,
          'dateTime': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============ REVIEWS ============

  /// Get all reviews for an event
  Future<List<EventReview>> getReviews(int eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('reviews')
          .orderBy('dateTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventReview.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get user's review for an event
  Future<EventReview?> getUserReview(int eventId, String userId) async {
    try {
      final doc = await _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('reviews')
          .doc(userId)
          .get();

      if (doc.exists) {
        return EventReview.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add or update user's review
  Future<void> saveReview({
    required int eventId,
    required String authorId,
    required String authorName,
    required String reviewText,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('reviews')
          .doc(authorId)
          .set({
        'authorId': authorId,
        'authorName': authorName,
        'reviewText': reviewText,
        'dateTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user's review
  Future<void> deleteReview(int eventId, String userId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId.toString())
          .collection('reviews')
          .doc(userId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}

class EventReview {
  final String authorId;
  final String authorName;
  final String reviewText;
  final DateTime dateTime;

  EventReview({
    required this.authorId,
    required this.authorName,
    required this.reviewText,
    required this.dateTime,
  });

  factory EventReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventReview(
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      reviewText: data['reviewText'] ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
