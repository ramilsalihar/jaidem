import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaidem/core/utils/constants/app_font_size.dart';
import 'app_colors.dart';

class AppTextTheme extends TextTheme {
  AppTextTheme()
      : super(
          displayLarge: GoogleFonts.inter(
            fontSize: AppFontSize.displayLarge,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: AppFontSize.displayMedium,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: AppFontSize.displaySmall,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: AppFontSize.headlineLarge,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: AppFontSize.headlineMedium,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: AppFontSize.headlineSmall,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: AppFontSize.bodyLarge,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: AppFontSize.bodyMedium,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: AppFontSize.bodySmall,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: AppFontSize.labelLarge,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: AppFontSize.labelMedium,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: AppFontSize.labelSmall,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        );

  // Dark mode text theme
  AppTextTheme copyWithDarkMode() {
    return AppTextTheme._internal(
      displayLarge: displayLarge?.copyWith(color: Colors.white),
      displayMedium: displayMedium?.copyWith(color: Colors.white),
      displaySmall: displaySmall?.copyWith(color: Colors.white),
      headlineLarge: headlineLarge?.copyWith(color: Colors.white),
      headlineMedium: headlineMedium?.copyWith(color: Colors.white70),
      headlineSmall: headlineSmall?.copyWith(color: Colors.white70),
      bodyLarge: bodyLarge?.copyWith(color: Colors.white),
      bodyMedium: bodyMedium?.copyWith(color: Colors.white70),
      bodySmall: bodySmall?.copyWith(color: Colors.white60),
      labelLarge: labelLarge?.copyWith(color: Colors.white),
      labelMedium: labelMedium?.copyWith(color: Colors.white70),
      labelSmall: labelSmall?.copyWith(color: Colors.white60),
    );
  }

  const AppTextTheme._internal({
    super.displayLarge,
    super.displayMedium,
    super.displaySmall,
    super.headlineLarge,
    super.headlineMedium,
    super.headlineSmall,
    super.bodyLarge,
    super.bodyMedium,
    super.bodySmall,
    super.labelLarge,
    super.labelMedium,
    super.labelSmall,
  });

  // Custom helper method
  TextStyle customSubtitle({Color? color, FontWeight? fontWeight, double? fontSize}) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? AppFontSize.bodyMedium,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.grey,
    );
  }
}
