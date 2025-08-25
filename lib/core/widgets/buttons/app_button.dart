import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.minimumSize,
    this.padding,
    this.borderRadius = 60.0,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isDisabled || isLoading;
    
    // Ensure consistent sizing for both button types
    final Size buttonSize = minimumSize ?? Size(double.infinity, height ?? 50);
    final EdgeInsetsGeometry buttonPadding = padding ?? const EdgeInsets.symmetric(vertical: 20);
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isButtonDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isButtonDisabled 
                ? Colors.grey.shade400 
                : (borderColor ?? backgroundColor ?? AppColors.primary),
            width: 1.5,
          ),
          minimumSize: buttonSize, // Same size as elevated button
          padding: buttonPadding, // Same padding as elevated button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: _buildChild(context),
      );
    }

    return ElevatedButton(
      onPressed: isButtonDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isButtonDisabled 
            ? Colors.grey.shade400
            : (backgroundColor ?? AppColors.primary),
        foregroundColor: isButtonDisabled 
            ? Colors.grey.shade600
            : (textColor ?? Colors.white),
        minimumSize: buttonSize,
        padding: buttonPadding,
        elevation: isButtonDisabled ? 0 : 2,
        shadowColor: isButtonDisabled ? Colors.transparent : Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null 
              ? BorderSide(
                  color: isButtonDisabled 
                      ? Colors.grey.shade400 
                      : borderColor!, 
                  width: 1.5,
                )
              : BorderSide.none,
        ),
        // Force the background color to be applied
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.grey.shade600,
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade400;
            }
            return backgroundColor ?? AppColors.primary;
          },
        ),
      ),
      child: _buildChild(context),
    );
  }

  Widget _buildChild(BuildContext context) {
    final bool isButtonDisabled = isDisabled || isLoading;
    
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined 
                ? (textColor ?? AppColors.primary)
                : (textColor ?? Colors.white),
          ),
        ),
      );
    }

    Color finalTextColor;
    if (isButtonDisabled) {
      finalTextColor = Colors.grey.shade600;
    } else if (isOutlined) {
      finalTextColor = textColor ?? backgroundColor ?? AppColors.primary;
    } else {
      finalTextColor = textColor ?? Colors.white;
    }

    return Text(
      text,
      style: context.textTheme.headlineMedium?.copyWith(
        color: finalTextColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
