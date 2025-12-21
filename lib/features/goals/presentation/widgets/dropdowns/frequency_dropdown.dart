import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class FrequencyDropdown extends StatelessWidget {
  final String? selectedFrequency;
  final ValueChanged<String> onChanged;
  final String label;
  final String hintText;

  const FrequencyDropdown({
    super.key,
    required this.selectedFrequency,
    required this.onChanged,
    this.label = 'Частота',
    this.hintText = 'Выберите частоту',
  });

  static const List<String> frequencies = [
    'Каждый день',
    'Каждую неделю',
    'Дважды в неделю',
    'Трижды в неделю',
    'Каждые выходные',
    'Каждый месяц',
    'Дважды в месяц',
    'Каждые 3 дня',
    'По будням',
    'Один раз',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedFrequency,
            hint: Text(
              hintText,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
            dropdownColor: Colors.white,
            style: context.textTheme.bodyMedium,
            items: frequencies.map((String frequency) {
              return DropdownMenuItem<String>(
                value: frequency,
                child: Text(frequency),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                onChanged(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, выберите частоту';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
