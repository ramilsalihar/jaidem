import 'package:flutter/material.dart';
import '../utils/style/app_colors.dart';

class AppTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}
