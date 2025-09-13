import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField(
      {super.key,
      required this.label,
      required this.hintText,
      required this.controller,
      this.textStyle,
      this.readOnly,
      this.trailing,
      this.maxLines});

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextStyle? textStyle;
  final bool? readOnly;
  final Widget? trailing;
  final int? maxLines;

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
          readOnly: readOnly ?? false,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            labelStyle: context.textTheme.bodyMedium,
            hintText: hintText,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            suffixIcon: trailing,
            border: _buildBorder(),
            focusedBorder: _buildBorder(),
            enabledBorder: _buildBorder(),
          ),
          maxLines: maxLines,
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
