import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/helpers/dropdown_mixin.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class StatisticsModeDropdown extends StatelessWidget with DropdownMixin {
  final String mode;
  final Function(String) onChanged;

  const StatisticsModeDropdown({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  String get _modeLabel => mode == 'month' ? 'Месяц' : 'Неделя';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showModeMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _modeLabel,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  void _showModeMenu(BuildContext context) {
    final dropdownItems = [
      const DropdownItem<String>(
        value: 'week',
        label: 'Неделя',
        selectedColor: AppColors.secondary,
      ),
      const DropdownItem<String>(
        value: 'month',
        label: 'Месяц',
        selectedColor: AppColors.secondary,
      ),
    ];

    showCustomDropdown<String>(
      context: context,
      items: dropdownItems,
      selectedValue: mode,
      onItemSelected: onChanged,
      maxHeight: 120,
    );
  }
}
