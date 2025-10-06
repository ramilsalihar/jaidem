import 'package:flutter/material.dart';
import 'package:jaidem/features/menu/presentation/pages/chats/chat_page.dart';

/// Example usage of the updated ChatPage with different chat types
class ChatPageExamples {
  
  /// Navigate to chat with a specific user
  static void openChatWithUser(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatType: 'users',
          userId: userId,
        ),
      ),
    );
  }

  /// Navigate to chat with mentor
  static void openChatWithMentor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatPage(
          chatType: 'mentors',
        ),
      ),
    );
  }

  /// Navigate to chat with admin
  static void openChatWithAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatPage(
          chatType: 'admin',
        ),
      ),
    );
  }
}
