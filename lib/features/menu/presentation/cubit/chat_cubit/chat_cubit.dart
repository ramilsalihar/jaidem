import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';
import 'package:jaidem/features/menu/domain/usecases/get_messages_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/send_message_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_chats_usecase.dart';
import 'package:jaidem/features/menu/domain/usecases/get_users_usecase.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetChatsUseCase getChatsUseCase;
  final GetUsersUseCase getUsersUseCase;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.getChatsUseCase,
    required this.getUsersUseCase,
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
}
