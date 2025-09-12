import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id; // document ID
  final String message;
  final String createdAt;
  final String authorId;
  final bool isRead; // LOCAL only

  NotificationModel({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.authorId,
    this.isRead = false,
  });

  factory NotificationModel.fromFirebase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      message: data['message'] ?? '',
      createdAt: data['createdAt'] ?? '',
      authorId: data['authorId'] ?? '',
    );
  }
}
