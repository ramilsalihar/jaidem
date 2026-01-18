import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';
import 'package:jaidem/features/menu/domain/usecases/get_messages_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chats_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_users_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chat_with_user_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chat_with_mentor_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chat_with_admin_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_to_user_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_to_mentor_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_to_admin_usecase.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetChatsUseCase getChatsUseCase;
  final GetUsersUseCase getUsersUseCase;
  final GetChatWithUserUseCase getChatWithUserUseCase;
  final GetChatWithMentorUseCase getChatWithMentorUseCase;
  final GetChatWithAdminUseCase getChatWithAdminUseCase;
  final SendMessageToUserUseCase sendMessageToUserUseCase;
  final SendMessageToMentorUseCase sendMessageToMentorUseCase;
  final SendMessageToAdminUseCase sendMessageToAdminUseCase;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.getChatsUseCase,
    required this.getUsersUseCase,
    required this.getChatWithUserUseCase,
    required this.getChatWithMentorUseCase,
    required this.getChatWithAdminUseCase,
    required this.sendMessageToUserUseCase,
    required this.sendMessageToMentorUseCase,
    required this.sendMessageToAdminUseCase,
  }) : super(const ChatState());

  /// 🔹 Get list of chats for current user
  void getChats(String userId) {
    emit(state.copyWith(isChatListLoading: true, clearError: true));
    getChatsUseCase(userId).listen((either) {
      either.fold(
        (failure) => emit(state.copyWith(
          isChatListLoading: false,
          error: failure,
        )),
        (chats) => emit(state.copyWith(
          chats: chats,
          isChatListLoading: false,
        )),
      );
    });
  }

  /// 🔹 Get messages inside a chat
  void getMessages(String chatId, String chatType) {
    emit(state.copyWith(isMessagesLoading: true, clearError: true));
    getMessagesUseCase(chatId, chatType).listen((either) {
      either.fold(
        (failure) => emit(state.copyWith(
          isMessagesLoading: false,
          error: failure,
        )),
        (messages) => emit(state.copyWith(
          messages: messages,
          isMessagesLoading: false,
        )),
      );
    });
  }

  /// 🔹 Send a new message
  Future<void> sendMessage(
      String chatId, String chatType, MessageModel message) async {
    await sendMessageUseCase(chatId, chatType, message);
  }

  /// 🔹 Get list of users to chat with
  void getUsers() {
    emit(state.copyWith(isChatUsersLoading: true, clearError: true));
    getUsersUseCase().listen((either) {
      either.fold(
        (failure) => emit(state.copyWith(
          isChatUsersLoading: false,
          error: failure,
        )),
        (users) => emit(state.copyWith(
          chatUsers: users,
          isChatUsersLoading: false,
        )),
      );
    });
  }

  /// 🔹 Get chat with a specific user
  Future<ChatModel?> getChatWithUser(String userId) async {
    try {
      emit(state.copyWith(clearError: true));
      final chat = await getChatWithUserUseCase(userId);
      return chat;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  /// 🔹 Get chat with mentor
  Future<ChatModel?> getChatWithMentor() async {
    try {
      emit(state.copyWith(clearError: true));
      final chat = await getChatWithMentorUseCase();
      return chat;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  /// 🔹 Get chat with admin
  Future<ChatModel?> getChatWithAdmin() async {
    try {
      emit(state.copyWith(clearError: true));
      final chat = await getChatWithAdminUseCase();
      return chat;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  /// 🔹 Send message to a specific user (creates chat if doesn't exist)
  Future<void> sendMessageToUser(String userId, String messageText) async {
    try {
      emit(state.copyWith(clearError: true));
      await sendMessageToUserUseCase(userId, messageText);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// 🔹 Send message to mentor (creates chat if doesn't exist)
  Future<void> sendMessageToMentor(String messageText) async {
    try {
      emit(state.copyWith(clearError: true));
      await sendMessageToMentorUseCase(messageText);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// 🔹 Send message to admin (creates chat if doesn't exist)
  Future<void> sendMessageToAdmin(String messageText) async {
    try {
      emit(state.copyWith(clearError: true));
      await sendMessageToAdminUseCase(messageText);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
