import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class UserNameField extends StatelessWidget {
  const UserNameField({
    super.key,
    required this.fullname,
    this.rating,
  });

  final String fullname;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Online indicator dot
        // Container(
        //   width: 8,
        //   height: 8,
        //   decoration: const BoxDecoration(
        //     color: Colors.green,
        //     shape: BoxShape.circle,
        //   ),
        // ),

        // const SizedBox(width: 8),

        // Name
        Expanded(
          child: Text(
            fullname,
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Rating badge
        if (rating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rating!.toStringAsFixed(1),
              style: context.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
