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
    return Column(
      children: [
        _HorizontalTabSelector(
          selectedTab: selectedTab,
          onTabChanged: onTabChanged,
        ),
        if (selectedTab == 1) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: StatisticsModeDropdown(
              mode: statisticsMode,
              onChanged: onStatisticsModeChanged,
            ),
          ),
        ],
      ],
    );
  }
}

class _HorizontalTabSelector extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const _HorizontalTabSelector({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final List<String> _tabTitles = const ['Индикаторы', 'Статистика'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: List.generate(_tabTitles.length, (index) {
          final isSelected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? AppColors.secondary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _tabTitles[index],
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.secondary : AppColors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
