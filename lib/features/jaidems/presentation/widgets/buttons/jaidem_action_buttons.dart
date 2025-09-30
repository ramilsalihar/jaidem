import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class JaidemActionButtons extends StatelessWidget {
  const JaidemActionButtons({
    super.key,
    this.iconSize = 20.0,
    this.spaceBetweenIcons = 5.0,
    this.isButtonExtended = false,
    this.hasTrailingButton = true,
    this.onTap,
  });

  final double iconSize;
  final double spaceBetweenIcons;
  final bool isButtonExtended;
  final bool hasTrailingButton;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/whatsapp.png',
                width: iconSize,
                height: iconSize,
              ),
              SizedBox(width: spaceBetweenIcons),
              Image.asset(
                'assets/icons/chat_colored.png',
                width: iconSize,
                height: iconSize,
              ),
              SizedBox(width: spaceBetweenIcons),
              Image.asset(
                'assets/icons/insta.png',
                width: iconSize,
                height: iconSize,
              ),
            ],
          ),
        ),
        if (hasTrailingButton) ...[
          SizedBox(width: spaceBetweenIcons * 2),

          /// Profile button adapts its width
          Flexible(
            flex: isButtonExtended ? 3 : 1,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isButtonExtended ? 16 : 8,
                  vertical: isButtonExtended ? 8 : 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Профиль',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight:
                        isButtonExtended ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
