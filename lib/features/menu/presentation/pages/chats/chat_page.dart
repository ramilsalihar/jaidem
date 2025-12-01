import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/message_card.dart';
import 'package:jaidem/features/menu/presentation/widgets/fields/chat_message_field.dart';
import 'package:jaidem/features/menu/presentation/widgets/layout/chat_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final String chatType;
  final String? userId; // Optional userId for user-to-user chats

  const ChatPage({
    super.key,
    required this.chatType,
    this.userId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final chatCubit = context.read<ChatCubit>();
    
    try {
      // Get the appropriate chat based on chat type
      switch (widget.chatType.toLowerCase()) {
        case 'users':
          if (widget.userId != null) {
            final chat = await chatCubit.getChatWithUser(widget.userId!);
            if (chat != null) {
              chatId = chat.id;
              chatCubit.getMessages(chat.id, widget.chatType);
            }
          }
          break;
        case 'mentors':
          final chat = await chatCubit.getChatWithMentor();
          if (chat != null) {
            chatId = chat.id;
            chatCubit.getMessages(chat.id, widget.chatType);
          }
          break;
        case 'admin':
          final chat = await chatCubit.getChatWithAdmin();
          if (chat != null) {
            chatId = chat.id;
            chatCubit.getMessages(chat.id, widget.chatType);
          }
          break;
      }
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final chatCubit = context.read<ChatCubit>();
    
    try {
      // Send message using the appropriate method based on chat type
      switch (widget.chatType.toLowerCase()) {
        case 'users':
          if (widget.userId != null) {
            await chatCubit.sendMessageToUser(widget.userId!, messageText);
            // If this is the first message, initialize chat after sending
            if (chatId == null) {
              await _initializeChat();
            }
          }
          break;
        case 'mentors':
          await chatCubit.sendMessageToMentor(messageText);
          // If this is the first message, initialize chat after sending
          if (chatId == null) {
            await _initializeChat();
          }
          break;
        case 'admin':
          await chatCubit.sendMessageToAdmin(messageText);
          // If this is the first message, initialize chat after sending
          if (chatId == null) {
            await _initializeChat();
          }
          break;
      }
      
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getContactName() {
    switch (widget.chatType.toLowerCase()) {
      case 'users':
        return widget.userId != null ? 'Колдонуучу' : 'Чат';
      case 'mentors':
        return 'Насаатчы';
      case 'admin':
        return 'Администратор';
      default:
        return 'Чат';
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: ChatAppBar(
          contactName: _getContactName(),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state.messages.isNotEmpty) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state.isMessagesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null && state.messages.isEmpty) {
                    return Center(child: Text(state.error!));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final currentUserId = sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
                      return MessageCard(
                        message: state.messages[index],
                        currentUserId: currentUserId,
                      );
                    },
                  );
                },
              ),
            ),
            ChatMessageField(
              controller: _messageController,
              onMessageSent: (_) => _sendMessage(),
            ),
          ],
        ),
 
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
