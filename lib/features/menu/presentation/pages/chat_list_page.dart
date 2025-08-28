import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/chat_over_view_card.dart';

@RoutePage()
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Чат',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: kToolbarHeight,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return ChatOverViewCard(
              profileImageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTyzTWQoCUbRNdiyorem5Qp1zYYhpliR9q0Bw&s',
              name: 'Пользователь ${index + 1}',
              date: '12:34',
              messagePreview:
                  'Последнее сообщение от пользователя ${index + 1}',
            );
          },
        ),
      ),
    );
  }
}
