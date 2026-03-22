import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/services/usage_service.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/helpers/content_filter.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidem_detail_page.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/message_card.dart';
import 'package:jaidem/features/menu/presentation/widgets/fields/chat_message_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final String chatType;
  final String? chatId;
  final String? userId;
  final String? userName;
  final String? userAvatar;

  const ChatPage({
    super.key,
    required this.chatType,
    this.chatId,
    this.userId,
    this.userName,
    this.userAvatar,
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

    // If chatId was passed directly (e.g. from chat list), use it
    if (widget.chatId != null) {
      chatId = widget.chatId;
      chatCubit.getMessages(chatId!, widget.chatType);
      return;
    }

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

    if (ContentFilter().containsObjectionableContent(messageText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('content_filtered_warning')),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

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

  void _markUnreadMessages(List<MessageModel> messages) {
    if (chatId == null) return;
    final currentUserId =
        sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
    if (currentUserId.isEmpty) return;

    final datasource = sl<MenuRemoteDatasource>();
    for (final msg in messages) {
      if (msg.senderId != currentUserId && !msg.readBy.contains(currentUserId)) {
        datasource.markMessageAsRead(chatId!, msg.id, currentUserId, widget.chatType);
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

  Future<void> _openJaidemProfile() async {
    final userId = int.tryParse(widget.userId ?? '');
    if (userId == null) return;

    final person = await context.read<JaidemsCubit>().getJaidemById(userId);
    if (person != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => JaidemDetailPage(person: person),
        ),
      );
    }
  }

  String _getContactName() {
    switch (widget.chatType.toLowerCase()) {
      case 'users':
        return widget.userName ?? 'Колдонуучу';
      case 'mentors':
        return 'Насаатчы';
      case 'admin':
        return 'Администратор';
      default:
        return 'Чат';
    }
  }

  String _getChatTypeLabel() {
    switch (widget.chatType.toLowerCase()) {
      case 'mentors':
        return 'Насаатчы';
      case 'admin':
        return 'Администратор';
      default:
        return 'Жеке чат';
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

                    // Contact avatar + info (tappable for users)
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.chatType == 'users' && widget.userId != null
                            ? () => _openJaidemProfile()
                            : null,
                        child: Row(
                          children: [
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
                                child: widget.userAvatar != null && widget.userAvatar!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(widget.userAvatar!),
                                        backgroundColor: contactColor.withValues(alpha: 0.1),
                                      )
                                    : Container(
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
                                  Text(
                                    _getChatTypeLabel(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                if (state.currentChatId == chatId && state.messages.isNotEmpty) {
                  _scrollToBottom();
                  _markUnreadMessages(state.messages);
                }
              },
              builder: (context, state) {
                // Only show messages belonging to this chat
                if (state.currentChatId != chatId) {
                  return const SizedBox.shrink();
                }

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

                final currentUserId =
                    sl<SharedPreferences>().getString(AppConstants.userId) ?? '';
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final showDateHeader = index == 0 ||
                        !_isSameDay(
                          state.messages[index - 1].createdAt,
                          message.createdAt,
                        );
                    return Column(
                      children: [
                        if (showDateHeader) _buildDateHeader(message.createdAt),
                        MessageCard(
                          message: message,
                          currentUserId: currentUserId,
                        ),
                      ],
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    String label;
    if (_isSameDay(date, now)) {
      label = 'Бүгүн';
    } else if (_isSameDay(date, yesterday)) {
      label = 'Кечээ';
    } else {
      label =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
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
