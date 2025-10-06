import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';

/// Example usage of the new ChatCubit methods
class ChatService {
  final ChatCubit chatCubit;

  ChatService(this.chatCubit);

  /// Example: Start a chat with a specific user
  Future<void> startChatWithUser(String userId, String initialMessage) async {
    // First try to get existing chat
    final existingChat = await chatCubit.getChatWithUser(userId);
    
    if (existingChat != null) {
      // Chat exists, load messages
      chatCubit.getMessages(existingChat.id, 'users');
    }
    
    // Send message (will create chat if it doesn't exist)
    await chatCubit.sendMessageToUser(userId, initialMessage);
  }

  /// Example: Contact mentor with a question
  Future<void> contactMentor(String question) async {
    // First try to get existing chat with mentor
    final existingChat = await chatCubit.getChatWithMentor();
    
    if (existingChat != null) {
      // Chat exists, load messages
      chatCubit.getMessages(existingChat.id, 'mentors');
    }
    
    // Send message to mentor (will create chat if it doesn't exist)
    await chatCubit.sendMessageToMentor(question);
  }

  /// Example: Contact admin for support
  Future<void> contactAdmin(String supportMessage) async {
    // First try to get existing chat with admin
    final existingChat = await chatCubit.getChatWithAdmin();
    
    if (existingChat != null) {
      // Chat exists, load messages
      chatCubit.getMessages(existingChat.id, 'admin');
    }
    
    // Send message to admin (will create chat if it doesn't exist)
    await chatCubit.sendMessageToAdmin(supportMessage);
  }

  /// Example: Quick help method to determine chat type from user role
  Future<void> sendQuickMessage(String userRole, String userId, String message) async {
    switch (userRole.toLowerCase()) {
      case 'mentor':
        await chatCubit.sendMessageToMentor(message);
        break;
      case 'admin':
        await chatCubit.sendMessageToAdmin(message);
        break;
      case 'user':
      default:
        await chatCubit.sendMessageToUser(userId, message);
        break;
    }
  }
}
