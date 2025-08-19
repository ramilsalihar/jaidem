import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextTheme extends TextTheme {
  AppTextTheme()
      : super(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 10,
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

  AppTextTheme._internal({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) : super(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          displaySmall: displaySmall,
          headlineLarge: headlineLarge,
          headlineMedium: headlineMedium,
          headlineSmall: headlineSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelLarge,
          labelMedium: labelMedium,
          labelSmall: labelSmall,
        );

  // Custom helper method
  TextStyle customSubtitle({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.grey,
    );
  }
}
