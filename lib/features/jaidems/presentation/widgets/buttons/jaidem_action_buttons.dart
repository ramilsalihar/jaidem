import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

const _iconSize = 25.0;

class JaidemActionButtons extends StatelessWidget {
  const JaidemActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Social Media Icons
        Image.asset(
          'assets/icons/whatsapp.png',
          width: _iconSize,
          height: _iconSize,
        ),
        const SizedBox(width: 5),
        Image.asset(
          'assets/icons/chat_colored.png',
          width: _iconSize,
          height: _iconSize,
        ),
        const SizedBox(width: 5),
        Image.asset(
          'assets/icons/insta.png',
          width: _iconSize,
          height: _iconSize,
        ),

        const Spacer(),

        // Profile Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text(
            'Профиль',
            style: context.textTheme.labelMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
