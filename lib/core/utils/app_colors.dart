import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /* ================== BRAND COLORS ================== */

  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryDark = Color(0xFF1E40AF); // Blue 800
  static const Color primaryLight = Color(0xFF93C5FD); // Blue 300

  /* ================== BACKGROUND & SURFACE ================== */

  static const Color background = Color(0xFFF8F9FB); // App background
  static const Color surface = Color(0xFFFFFFFF); // Cards / Drawer
  static const Color surfaceSoft = Color(0xFFF1F5F9); // Sections

  /* ================== TEXT COLORS ================== */

  static const Color textPrimary = Color(0xFF111827); // Headings
  static const Color textSecondary = Color(0xFF6B7280); // Sub text
  static const Color textDisabled = Color(0xFF9CA3AF); // Disabled
  static const Color textOnPrimary = Color(0xFFFFFFFF); // On primary bg
  static const Color textLight = Color(0xB3FFFFFF); // White 70%

  /* ================== BORDER & DIVIDER ================== */

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE5E7EB);

  /* ================== STATUS COLORS ================== */

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  /* ================== DARK / GRADIENT ================== */

  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);

  //static const background = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const title = Color(0xFF1E293B);
  static const body = Color(0xFF475569);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111827), // charcoal
      Color(0xFF1E3A8A), // deep blue
      Color(0xFF312E81), // indigo
    ],
  );

  static const LinearGradient drawerColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF111827), // gray-900
      Color(0xFF1F2937), // gray-800
    ],
  );
}
