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
import 'package:jaidem/features/goals/presentation/pages/goals_page.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidems_page.dart';
import 'package:jaidem/features/profile/presentation/pages/profile_page.dart';

@RoutePage()
class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    context.read<EventsCubit>().fetchEvents();
    Future.microtask(() {
      if (mounted) context.read<ForumCubit>().fetchAllForums();
    });
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
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
          GoalsPage(),
          EventsPage(),
          ProfilePage()
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
              _buildCenterButton(),
              _buildNavItem(
                index: 3,
                icon: Icons.event_outlined,
                activeIcon: Icons.event_rounded,
                label: context.tr('nav_events'),
              ),
              _buildNavItem(
                index: 4,
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    final isSelected = _selectedIndex == 2;

    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [AppColors.primary, AppColors.primary.shade700]
                : [AppColors.primary.shade300, AppColors.primary.shade500],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.primary.withValues(alpha: isSelected ? 0.4 : 0.25),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.05 : 1.0,
          child: const Icon(
            Icons.flag_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
