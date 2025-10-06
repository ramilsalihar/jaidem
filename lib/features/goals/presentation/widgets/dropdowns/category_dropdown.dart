import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onChanged;
  final String label;
  final String hintText;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.label = 'Категория',
    this.hintText = 'Выберите категорию',
  });

  static const List<String> categories = [
    'Учеба',
    'Работа',
    'Здоровье',
    'Спорт',
    'Финансы',
    'Семья',
    'Хобби',
    'Путешествия',
    'Личностный рост',
    'Карьера',
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
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
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
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                onChanged(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, выберите категорию';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
