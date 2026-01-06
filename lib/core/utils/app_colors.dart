import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1E3A8A); // from gradient
  static const Color card = Colors.white;
  static const Color primary = Color(0xFF2563EB);
  static const Color textLight = Colors.white70;
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111827), // gray-900
      Color(0xFF1E3A8A), // blue-900
      Color(0xFF312E81), // indigo-900
    ],
  );
}
