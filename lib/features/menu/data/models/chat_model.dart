import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';

class ChatModel {
  final String id;
  final List<String> participants; // userIds
  final List<ChatUserModel> users; // participant details
  final String lastMessage;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.users,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      users: (data['users'] as List<dynamic>? ?? [])
          .map((u) => ChatUserModel.fromMap(u as Map<String, dynamic>))
          .toList(),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'users': users.map((u) => u.toMap()).toList(),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
