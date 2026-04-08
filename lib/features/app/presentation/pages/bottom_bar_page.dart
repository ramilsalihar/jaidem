import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/events/presentation/pages/events_page.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/pages/forum_page.dart';
import 'package:jaidem/features/goals/data/services/goal_reminder_service.dart';
import 'package:jaidem/features/goals/presentation/cubit/goals/goals_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidems_page.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/features/profile/presentation/pages/profile_page.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    final flowId = sl<SharedPreferences>().getInt('user_flow_id');
    context.read<EventsCubit>().fetchEvents(flowId: flowId);
    Future.microtask(() {
      if (mounted) context.read<ForumCubit>().fetchAllForums();
    });
    _pageController = PageController(initialPage: _selectedIndex);

    // Reschedule goal reminders on app startup (after login)
    _rescheduleGoalReminders();
  }

  Future<void> _rescheduleGoalReminders() async {
    try {
      final goalsCubit = context.read<GoalsCubit>();
      await goalsCubit.fetchGoals();
      final goals = goalsCubit.state.goals;
      if (goals.isNotEmpty) {
        await GoalReminderService().rescheduleAll(goals);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    HapticFeedback.mediumImpact();
    final userIdStr = sl<SharedPreferences>().getString(AppConstants.userId);
    final userId = int.tryParse(userIdStr ?? '');
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateEditPostSheet(
        userId: userId,
        onSuccess: () {
          context.read<ForumCubit>().fetchAllForums();
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          ForumPage(),
          JaidemsPage(),
          EventsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: context.tr('nav_home'),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
                label: context.tr('nav_jaidem'),
              ),
              _buildActionNavItem(
                icon: Icons.campaign_outlined,
                activeIcon: Icons.campaign_rounded,
                label: 'Жарыя',
                onTap: _openCreatePost,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.event_outlined,
                activeIcon: Icons.event_rounded,
                label: context.tr('nav_events'),
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: context.tr('nav_profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : Colors.grey.shade500,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
