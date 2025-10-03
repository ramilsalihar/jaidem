import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/statistics_mode_dropdown.dart';

class OverviewTabSelector extends StatelessWidget {
  final int selectedTab;
  final String statisticsMode;
  final Function(int) onTabChanged;
  final Function(String) onStatisticsModeChanged;

  const OverviewTabSelector({
    super.key,
    required this.selectedTab,
    required this.statisticsMode,
    required this.onTabChanged,
    required this.onStatisticsModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabDropdownButton(
          selectedTab: selectedTab,
          onTabChanged: onTabChanged,
        ),
        if (selectedTab == 1) ...[
          const Spacer(),
          StatisticsModeDropdown(
            mode: statisticsMode,
            onChanged: onStatisticsModeChanged,
          ),
        ],
      ],
    );
  }
}

class _TabDropdownButton extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const _TabDropdownButton({
    required this.selectedTab,
    required this.onTabChanged,
  });

  String get _selectedTitle => selectedTab == 0 ? 'Индикаторы' : 'Статистика';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _selectedTitle,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (selectedTab == 0) {
              onTabChanged(1);
            } else {
              onTabChanged(0);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
