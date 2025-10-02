import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';

abstract class MenuRemoteDatasource {
  Future<ChatModel> createChat(
    String currentUserId,
    String otherUserId,
    List<Map<String, dynamic>> users,
  );

  Stream<List<ChatModel>> getChats(String userId);

  Stream<List<MessageModel>> getMessages(String chatId, String chatType);

  Future<void> sendMessage(
    String chatId,
    String chatType,
    MessageModel message,
  );

  Future<void> markMessageAsRead(
    String chatId,
    String messageId,
    String userId,
    String chatType,
  );

  Stream<List<ChatUserModel>> getUsers();

}
