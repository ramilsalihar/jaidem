import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class ChatMessageField extends StatefulWidget {
  final Function(String)? onMessageSent;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onEmojiPressed;
  final String? hintText;
  final TextEditingController? controller;

  const ChatMessageField({
    super.key,
    this.onMessageSent,
    this.onAttachmentPressed,
    this.onEmojiPressed,
    this.hintText,
    this.controller,
  });

  @override
  State<ChatMessageField> createState() => _ChatMessageFieldState();
}

class _ChatMessageFieldState extends State<ChatMessageField> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _messageController.dispose();
    }
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onMessageSent?.call(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                size: 25,
              ),
              color: AppColors.black,
              onPressed: widget.onEmojiPressed ??
                  () {
                    // Handle emoji picker
                  },
            ),

            const SizedBox(width: 8),

            // Text input
            Expanded(
              child: TextField(
                controller: _messageController,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Жазууну баштоо...',
                  hintStyle: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: 8),

            // Attachment button
            GestureDetector(
              onTap: widget.onAttachmentPressed ??
                  () {
                    // Handle attachment
                  },
              child: Image.asset(
                'assets/icons/attach_file.png',
                height: 24,
              ),
            ),

            const SizedBox(width: 10),

            // Send button
            GestureDetector(
              onTap: _sendMessage,
              child: Image.asset(
                'assets/icons/send_icon.png',
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
