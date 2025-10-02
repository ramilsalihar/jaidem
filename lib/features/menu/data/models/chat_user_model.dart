import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUserModel {
  final String id;
  final String name;
  final String photoUrl;
  final String role; // "user" | "mentor" | "admin"

  ChatUserModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.role,
  });

  factory ChatUserModel.fromMap(Map<String, dynamic> data) {
    return ChatUserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  factory ChatUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatUserModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
