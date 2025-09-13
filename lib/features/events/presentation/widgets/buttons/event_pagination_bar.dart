import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/widgets/buttons/app_icon_button.dart';

class EventPaginationBar extends StatelessWidget {
  const EventPaginationBar({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w300,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          AppIconButton(
            icon: Icons.arrow_back_ios,
            onTap: () {
              controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          const SizedBox(width: 8),
          AppIconButton(
            icon: Icons.arrow_forward_ios,
            onTap: () {
              controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}
