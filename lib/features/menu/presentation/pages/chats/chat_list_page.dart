import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/chat_over_view_card.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<SharedPreferences>().getString(AppConstants.userId) ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Чат',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
            if (state.isChatListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            if (state.chats.isEmpty) {
              return const Center(child: Text("No chats yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: kToolbarHeight,
              ),
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];

                // Find the other user
                final otherUser = chat.users.firstWhere(
                  (u) => u.id != currentUserId,
                  orElse: () => chat.users.first,
                );

                return ChatOverViewCard(
                  profileImageUrl: otherUser.photoUrl,
                  name: otherUser.name,
                  date: _formatDate(chat.lastMessageAt),
                  messagePreview: chat.lastMessage,
                  onTap: () {
                    final chatType = otherUser.role == 'mentor' ? 'mentors' : 
                                   otherUser.role == 'admin' ? 'admin' : 'users';
                    context.router.push(
                      ChatRoute(chatType: chatType),
                    );
                  },
                );
              },
            );
          },
        ),

    );
  }

  String _formatDate(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
