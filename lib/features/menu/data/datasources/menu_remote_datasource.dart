import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/file_model.dart';
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

  // New methods for specific chat types
  Future<ChatModel?> getChatWithUser(String userId);
  Future<ChatModel?> getChatWithMentor();
  Future<ChatModel?> getChatWithAdmin();
  Future<void> sendMessageToUser(String userId, String messageText);
  Future<void> sendMessageToMentor(String messageText);
  Future<void> sendMessageToAdmin(String messageText);

  // Files
  Future<Either<String, ResponseModel<FileModel>>> getFiles();
}
