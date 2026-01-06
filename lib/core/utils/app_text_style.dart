import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AppTextStyle {
  static TextStyle heading = TextStyle(
    fontSize: Responsive.sp(18),
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = TextStyle(
    fontSize: Responsive.sp(14),
  );

  static TextStyle small = TextStyle(
    fontSize: Responsive.sp(12),
  );
}
