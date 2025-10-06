import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDatasource remoteDatasource;

  const MenuRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<String, ChatModel>> createChat(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      // ⚠️ You had `users` param undefined in your snippet
      // Here we pass empty list or handle it from UI/service
      final chat = await remoteDatasource.createChat(
        currentUserId,
        otherUserId,
        [], // <-- pass actual users list from UI/service layer
      );
      return Right(chat);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while creating chat');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<Either<String, List<ChatModel>>> getChats(String userId) async* {
    try {
      yield* remoteDatasource.getChats(userId).map((chats) => Right(chats));
    } on FirebaseException catch (e) {
      yield Left(e.message ?? 'Firebase error while fetching chats');
    } catch (e) {
      yield Left(e.toString());
    }
  }

  @override
  Stream<Either<String, List<MessageModel>>> getMessages(
      String chatId, String chatType) async* {
    try {
      yield* remoteDatasource
          .getMessages(chatId, chatType)
          .map((messages) => Right(messages));
    } on FirebaseException catch (e) {
      yield Left(e.message ?? 'Firebase error while fetching messages');
    } catch (e) {
      yield Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markMessageAsRead(
    String chatId,
    String messageId,
    String userId,
    String chatType,
  ) async {
    try {
      await remoteDatasource.markMessageAsRead(
          chatId, messageId, userId, chatType);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while marking as read');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendMessage(
    String chatId,
    String chatType,
    MessageModel message,
  ) async {
    try {
      await remoteDatasource.sendMessage(chatId, chatType, message);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while sending message');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<Either<String, List<ChatUserModel>>> getUsers() async* {
    try {
      yield* remoteDatasource.getUsers().map((users) => Right(users));
    } on FirebaseException catch (e) {
      yield Left(e.message ?? 'Firebase error while fetching users');
    } catch (e) {
      yield Left(e.toString());
    }
  }

  @override
  Future<Either<String, ChatModel?>> getChatWithUser(String userId) async {
    try {
      final chat = await remoteDatasource.getChatWithUser(userId);
      return Right(chat);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while fetching chat with user');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ChatModel?>> getChatWithMentor() async {
    try {
      final chat = await remoteDatasource.getChatWithMentor();
      return Right(chat);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while fetching chat with mentor');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ChatModel?>> getChatWithAdmin() async {
    try {
      final chat = await remoteDatasource.getChatWithAdmin();
      return Right(chat);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while fetching chat with admin');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendMessageToUser(String userId, String messageText) async {
    try {
      await remoteDatasource.sendMessageToUser(userId, messageText);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while sending message to user');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendMessageToMentor(String messageText) async {
    try {
      await remoteDatasource.sendMessageToMentor(messageText);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while sending message to mentor');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendMessageToAdmin(String messageText) async {
    try {
      await remoteDatasource.sendMessageToAdmin(messageText);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.message ?? 'Firebase error while sending message to admin');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
