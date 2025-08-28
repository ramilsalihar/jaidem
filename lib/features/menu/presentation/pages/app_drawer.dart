import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/buttons/menu_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      width: size.width * 0.75,
      backgroundColor: Colors.transparent,
      child: Container(
        height: size.height,
        margin: const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: size.width,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B46C1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'JAIDEM',
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w100,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            MenuButton(
                              title: 'База знаний',
                              onTap: () {
                                Navigator.pop(context);
                              },
                              leadingIcon: 'assets/icons/backpack.png',
                            ),
                            MenuButton(
                              title: 'Чат',
                              onTap: () {
                                Navigator.pop(context);
                              },
                              leadingIcon: 'assets/icons/chat.png',
                            ),
                            MenuButton(
                              title: 'Чат с Админом',
                              onTap: () {
                                Navigator.pop(context);
                              },
                              leadingIcon: 'assets/icons/chat.png',
                            ),
                            MenuButton(
                              title: 'Чат с ментором',
                              onTap: () {
                                Navigator.pop(context);
                              },
                              leadingIcon: 'assets/icons/chat.png',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Настройки',
                                style: context.textTheme.bodyMedium,
                              ),
                            ),
                            MenuButton(
                              title: 'Уведомления',
                              onTap: () {},
                              leadingIcon: 'assets/icons/notification.png',
                              trailing: SizedBox(
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    value: true,
                                    onChanged: (bool value) {},
                                    activeTrackColor: AppColors.primary,
                                  ),
                                ),
                              ),
                              onTrailingPressed: () {},
                            ),
                            MenuButton(
                              title: 'Смена пароля',
                              onTap: () {
                                context.router.push(ChangePasswordRoute());
                              },
                              leadingIcon: 'assets/icons/password.png',
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocListener<MenuCubit, MenuState>(
              listener: (context, state) {
                if (state is MenuSignOutSuccess) {
                  context.router.replaceAll([LoginRoute()]);
                } else if (state is MenuError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign out failed: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<MenuCubit, MenuState>(
                builder: (context, state) {
                  final isLoading = state is MenuLoading;
                  
                  return GestureDetector(
                    onTap: isLoading ? null : () {
                      _showSignOutDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Row(
                        children: [
                          if (isLoading)
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            Image.asset(
                              'assets/icons/exit.png',
                              color: AppColors.white,
                              height: 24,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            isLoading ? 'Выходим...' : 'Выйти',
                            style: context.textTheme.displaySmall?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Выйти из аккаунта'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<MenuCubit>().signOut();
              },
              child: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
