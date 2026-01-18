import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/services/usage_service.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/message_card.dart';
import 'package:jaidem/features/menu/presentation/widgets/fields/chat_message_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final String chatType;
  final String? userId;

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
    UsageService().updateChatLastUsedTime();
  }

  Future<void> _initializeChat() async {
    final chatCubit = context.read<ChatCubit>();

    try {
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
      debugPrint('Error initializing chat: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final chatCubit = context.read<ChatCubit>();

    try {
      switch (widget.chatType.toLowerCase()) {
        case 'users':
          if (widget.userId != null) {
            await chatCubit.sendMessageToUser(widget.userId!, messageText);
            if (chatId == null) {
              await _initializeChat();
            }
          }
          break;
        case 'mentors':
          await chatCubit.sendMessageToMentor(messageText);
          if (chatId == null) {
            await _initializeChat();
          }
          break;
        case 'admin':
          await chatCubit.sendMessageToAdmin(messageText);
          if (chatId == null) {
            await _initializeChat();
          }
          break;
      }

      _messageController.clear();
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Билдирүү жөнөтүлгөн жок: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
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

  IconData _getContactIcon() {
    switch (widget.chatType.toLowerCase()) {
      case 'mentors':
        return Icons.school_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getContactColor() {
    switch (widget.chatType.toLowerCase()) {
      case 'mentors':
        return AppColors.primary;
      case 'admin':
        return AppColors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactColor = _getContactColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Modern App Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                      onPressed: () => context.router.pop(),
                    ),

                    const SizedBox(width: 8),

                    // Contact avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            contactColor,
                            contactColor.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                contactColor.withValues(alpha: 0.1),
                                contactColor.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            _getContactIcon(),
                            color: contactColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Contact info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getContactName(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.green.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Онлайн',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.messages.isNotEmpty) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state.isMessagesLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Билдирүүлөр жүктөлүүдө...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state.error != null && state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: contactColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 56,
                            color: contactColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Билдирүүлөр жок',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Биринчи билдирүүңүздү жөнөтүңүз!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final currentUserId =
                        sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
                    return MessageCard(
                      message: state.messages[index],
                      currentUserId: currentUserId,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
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
