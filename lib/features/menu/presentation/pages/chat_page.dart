import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/message_card.dart';
import 'package:jaidem/features/menu/presentation/widgets/fields/chat_message_field.dart';
import 'package:jaidem/features/menu/presentation/widgets/layout/chat_app_bar.dart';

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

@RoutePage()
class ChatPage extends StatefulWidget {
  final String contactName;
  final String contactStatus;
  final String? contactAvatarUrl;
  final List<Message>? initialMessages;
  final Function(String)? onSendMessage;
  final VoidCallback? onBackPressed;
  final VoidCallback? onAttachmentPressed;

  const ChatPage({
    super.key,
    required this.contactName,
    required this.contactStatus,
    this.contactAvatarUrl,
    this.initialMessages,
    this.onSendMessage,
    this.onBackPressed,
    this.onAttachmentPressed,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Message> messages;

  @override
  void initState() {
    super.initState();
    messages = widget.initialMessages ?? [];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      text: _messageController.text.trim(),
      isMe: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(message);
    });

    widget.onSendMessage?.call(_messageController.text.trim());
    _messageController.clear();

    // Scroll to bottom
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: ChatAppBar(
        contactName: widget.contactName,
        contactStatus: widget.contactStatus,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageCard(message: messages[index]);
              },
            ),
          ),
          ChatMessageField(
            controller: _messageController,
            onMessageSent: (p0) => _sendMessage(),
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

List<Message> messages = [
  Message(
    text: 'Здравствуйте, меня зовут Асан Асанов',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Message(
    text: 'Здравствуйте, очень приятно',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
  ),
  Message(
    text: 'Хотел спросить на счет совместного проекта',
    isMe: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  Message(
    text: 'Когда у вас будет время?',
    isMe: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
  ),
];
