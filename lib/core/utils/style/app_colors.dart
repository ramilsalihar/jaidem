import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF3C2A98);
  static const Color secondary = Color(0xFFFF854A);
  
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Additional Colors
  static const Color barColor = Color(0xFFF0F0F0);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  
  // Generate Material Color from primary
  static MaterialColor get primarySwatch => _generateMaterialColor(primary);
  static MaterialColor get secondarySwatch => _generateMaterialColor(secondary);
  
  static MaterialColor _generateMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;
    
    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };
    
    return MaterialColor(color.value, shades);
  }
}
