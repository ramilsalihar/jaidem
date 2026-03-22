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
  final String? chatType; // 'users', 'mentors', 'admin'
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.participants,
    required this.users,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.chatType,
    this.unreadCount = 0,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final users = (data['users'] as List<dynamic>? ?? [])
        .map((u) => ChatUserModel.fromMap(u as Map<String, dynamic>))
        .toList();

    // Fix users with empty id by matching from participants
    final hasEmptyId = users.any((u) => u.id.isEmpty);
    if (hasEmptyId && participants.isNotEmpty) {
      final usedIds = users.where((u) => u.id.isNotEmpty).map((u) => u.id).toSet();
      final missingIds = participants.where((p) => !usedIds.contains(p)).toList();
      int missingIndex = 0;

      for (int i = 0; i < users.length; i++) {
        if (users[i].id.isEmpty && missingIndex < missingIds.length) {
          users[i] = ChatUserModel(
            id: missingIds[missingIndex],
            name: users[i].name,
            photoUrl: users[i].photoUrl,
            role: users[i].role,
          );
          missingIndex++;
        }
      }

      // Fire-and-forget Firestore fix (won't re-trigger since ids are now filled)
      try {
        doc.reference.update({
          'users': users.map((u) => u.toMap()).toList(),
        });
      } catch (_) {}
    }

    return ChatModel(
      id: doc.id,
      participants: participants,
      users: users,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ChatModel copyWith({
    int? unreadCount,
    String? chatType,
  }) {
    return ChatModel(
      id: id,
      participants: participants,
      users: users,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      chatType: chatType ?? this.chatType,
      unreadCount: unreadCount ?? this.unreadCount,
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
