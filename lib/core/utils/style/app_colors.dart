import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color secondary = Color(0xFFFF854A);

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFECEFF6);
  static const Color darkGrey = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Additional Colors
  static const Color barColor = Color(0xFFF0F0F0);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Color(0xFFF4F0FA);

  static const Color green = Color(0xFF589E67);
  static const Color orange = Color(0xFFFD7F00);
  static const Color red = Color(0xFFAF4B4B);

  static const int _primaryValue = 0xFF3C2A98;

  static const MaterialColor primary = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFECEAF6),
      100: Color(0xFFC5BFE8),
      200: Color(0xFF9D93D9),
      300: Color(0xFF7567CA),
      400: Color(0xFF5746BE),
      500: Color(_primaryValue),
      600: Color(0xFF36268A),
      700: Color(0xFF2E1F79),
      800: Color(0xFF271967),
      900: Color(0xFF1A0F4B),
    },
  );
}
