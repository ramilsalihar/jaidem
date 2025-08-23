import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.textStyle,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            labelStyle: context.textTheme.bodyMedium,
            hintText: hintText,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            border: _buildBorder(),
            focusedBorder: _buildBorder(),
            enabledBorder: _buildBorder(),
          ),
        ),
      ],
    );
  }

  InputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: BorderSide(
        color: AppColors.grey,
      ),
    );
  }
}
