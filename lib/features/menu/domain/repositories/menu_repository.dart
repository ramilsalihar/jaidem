import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';

abstract class MenuRepository {
  Future<Either<String, ChatModel>> createChat(
    String currentUserId,
    String otherUserId,
  );

  // Get list of chats for a user
  Stream<Either<String, List<ChatModel>>> getChats(String userId);

  // Get messages inside a chat
  Stream<Either<String, List<MessageModel>>> getMessages(
      String chatId, String chatType);

  // Send message
  Future<Either<String, void>> sendMessage(
    String chatId,
    String chatType,
    MessageModel message,
  );

  // Mark message as read
  Future<Either<String, void>> markMessageAsRead(
    String chatId,
    String messageId,
    String userId,
    String chatType,
  );

  // Get list of users to chat with
  Stream<Either<String, List<ChatUserModel>>> getUsers();
}
