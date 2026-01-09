import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AppSnackBar {
  AppSnackBar._();

  /// ✅ SUCCESS
  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  /// ❌ ERROR
  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  /// ⚠️ WARNING
  static void warning(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Common SnackBar - Now appears higher on screen
  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          // This pushes it up from the bottom
          margin: EdgeInsets.only(
            left: Responsive.w(12),
            right: Responsive.w(12),
            bottom: MediaQuery.of(context).size.height *
                0.25, // Key line: Adjust this
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: Responsive.sp(24),
              ),
              SizedBox(width: Responsive.w(12)),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
