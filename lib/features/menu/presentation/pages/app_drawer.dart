import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/localization/locale_cubit.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/presentation/dialogs/terms_dialog.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit/menu_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/buttons/menu_button.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _showTrainings = false;

  @override
  void initState() {
    super.initState();
    _checkTrainingsVisibility();
  }

  Future<void> _checkTrainingsVisibility() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('trainings')
          .doc('tr')
          .get();
      if (mounted) {
        setState(() {
          _showTrainings = doc.data()?['show'] == true;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context, topPadding),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(context.tr('main_section')),
                  MenuButton(
                    title: context.tr('knowledge_base'),
                    iconData: Icons.folder_open_rounded,
                    iconBackgroundColor: Colors.blue.shade50,
                    iconColor: Colors.blue.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(FilesRoute());
                    },
                  ),
                  if (_showTrainings)
                    MenuButton(
                      title: context.tr('trainings'),
                      iconData: Icons.school_rounded,
                      iconBackgroundColor: Colors.cyan.shade50,
                      iconColor: Colors.cyan.shade600,
                      onTap: () {
                        Navigator.pop(context);
                        context.router.push(TrainingsRoute());
                      },
                    ),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, chatState) {
                      final totalUnread = chatState.chats.fold<int>(
                        0, (sum, chat) => sum + chat.unreadCount,
                      );
                      return MenuButton(
                        title: context.tr('chat_list'),
                        iconData: Icons.chat_bubble_outline_rounded,
                        iconBackgroundColor: Colors.green.shade50,
                        iconColor: Colors.green.shade600,
                        trailing: totalUnread > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  totalUnread > 99 ? '99+' : totalUnread.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(ChatListRoute());
                        },
                      );
                    },
                  ),
                  MenuButton(
                    title: context.tr('chat_with_admin'),
                    iconData: Icons.admin_panel_settings_outlined,
                    iconBackgroundColor: Colors.orange.shade50,
                    iconColor: Colors.orange.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(ChatRoute(chatType: 'admin'));
                    },
                  ),
                  MenuButton(
                    title: context.tr('chat_with_mentor'),
                    iconData: Icons.people_outline_rounded,
                    iconBackgroundColor: Colors.purple.shade50,
                    iconColor: Colors.purple.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(AdvisorsRoute());
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(color: Colors.grey.shade100, height: 1),
                  ),

                  _buildSectionLabel(context.tr('settings_section')),
                  MenuButton(
                    title: context.tr('notifications'),
                    iconData: Icons.notifications_outlined,
                    iconBackgroundColor: Colors.amber.shade50,
                    iconColor: Colors.amber.shade700,
                    onTap: () {},
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: true,
                        onChanged: (bool value) {},
                        activeTrackColor: AppColors.primary,
                      ),
                    ),
                    onTrailingPressed: () {},
                  ),
                  MenuButton(
                    title: context.tr('change_password'),
                    iconData: Icons.lock_outline_rounded,
                    iconBackgroundColor: Colors.teal.shade50,
                    iconColor: Colors.teal.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(ChangePasswordRoute());
                    },
                  ),
                  MenuButton(
                    title: context.tr('terms_title'),
                    iconData: Icons.description_outlined,
                    iconBackgroundColor: Colors.blueGrey.shade50,
                    iconColor: Colors.blueGrey.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => const TermsDialog(readOnly: true),
                      );
                    },
                  ),
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, currentLocale) {
                      final flag = LocaleCubit.localeFlags[currentLocale.languageCode] ?? '';
                      final name = LocaleCubit.localeNames[currentLocale.languageCode] ?? '';
                      return MenuButton(
                        title: 'Тил / Язык',
                        iconData: Icons.language_rounded,
                        iconBackgroundColor: Colors.indigo.shade50,
                        iconColor: Colors.indigo.shade600,
                        onTap: () => _showLanguageBottomSheet(context),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$flag $name',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildSignOutButton(context, bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 12, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JAIDEM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  context.tr('select_menu_item'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, double bottomPadding) {
    return BlocListener<MenuCubit, MenuState>(
      listener: (context, state) {
        if (state is MenuSignOutSuccess) {
          context.router.replaceAll([LoginRoute()]);
        } else if (state is MenuError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.tr('sign_out_failed')}: ${state.message}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          final isLoading = state is MenuLoading;
          return GestureDetector(
            onTap: isLoading ? null : () {
              HapticFeedback.mediumImpact();
              _showSignOutDialog(context);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding + 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
                      ),
                    )
                  else
                    Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isLoading ? context.tr('signing_out') : context.tr('sign_out'),
                    style: TextStyle(
                      color: Colors.red.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.logout_rounded, size: 28, color: Colors.red.shade400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('sign_out_confirm'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('sign_out_description'),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.tr('no'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop();
                              context.read<MenuCubit>().signOut();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.tr('yes_sign_out'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: localeCubit,
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, currentLocale) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          context.tr('select_language'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...LocaleCubit.supportedLocales.map((locale) {
                        final isSelected = currentLocale.languageCode == locale.languageCode;
                        final flag = LocaleCubit.localeFlags[locale.languageCode] ?? '';
                        final name = LocaleCubit.localeNames[locale.languageCode] ?? '';

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<LocaleCubit>().changeLocale(locale);
                            Navigator.pop(bottomSheetContext);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(flag, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? AppColors.primary : Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
