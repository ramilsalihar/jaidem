part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final List<ChatModel> chats;
  final List<MessageModel> messages;
  final List<ChatUserModel> chatUsers;
  final bool isChatListLoading;
  final bool isMessagesLoading;
  final bool isChatUsersLoading;
  final String? error;

  const ChatState({
    this.chats = const [],
    this.messages = const [],
    this.chatUsers = const [],
    this.isChatListLoading = false,
    this.isMessagesLoading = false,
    this.isChatUsersLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatModel>? chats,
    List<MessageModel>? messages,
    List<ChatUserModel>? chatUsers,
    bool? isChatListLoading,
    bool? isMessagesLoading,
    bool? isChatUsersLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      chatUsers: chatUsers ?? this.chatUsers,
      isChatListLoading: isChatListLoading ?? this.isChatListLoading,
      isMessagesLoading: isMessagesLoading ?? this.isMessagesLoading,
      isChatUsersLoading: isChatUsersLoading ?? this.isChatUsersLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        chats,
        messages,
        chatUsers,
        isChatListLoading,
        isMessagesLoading,
        isChatUsersLoading,
        error,
      ];
}
