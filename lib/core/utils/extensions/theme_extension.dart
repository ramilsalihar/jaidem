import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  Color get primaryColor => Theme.of(this).primaryColor;
  
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  Size get screenSize => MediaQuery.of(this).size;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  
  double get screenHeight => MediaQuery.of(this).size.height;
  
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
