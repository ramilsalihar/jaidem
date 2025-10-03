import 'package:flutter/material.dart';

class ProgressColorHelper {
  ProgressColorHelper._();

  static Color getColorForProgress(int progressPercent) {
    if (progressPercent == 100) {
      return Colors.green;
    } else if (progressPercent >= 50) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
