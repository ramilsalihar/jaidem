import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/message_card.dart';
import 'package:jaidem/features/menu/presentation/widgets/fields/chat_message_field.dart';
import 'package:jaidem/features/menu/presentation/widgets/layout/chat_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final String chatType;

  const ChatPage({
    super.key,
    required this.chatType,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch messages when entering this page
    context.read<ChatCubit>().getMessages('', widget.chatType);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
    final message = MessageModel(
      id: '', // Firestore generates this
      senderId: currentUserId,
      receiverId: '', // Will be set in datasource based on chat type
      text: _messageController.text.trim(),
      photoUrl: null,
      createdAt: DateTime.now(),
      readBy: [currentUserId], // Current user has read the message
    );

    context.read<ChatCubit>().sendMessage('', widget.chatType, message);
    _messageController.clear();
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

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: ChatAppBar(
          contactName: 'Чат',
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
