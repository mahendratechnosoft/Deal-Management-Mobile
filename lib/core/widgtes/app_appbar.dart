import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// REQUIRED
  final String title;

  /// OPTIONAL
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primaryDark,
      elevation: elevation,
      iconTheme: IconThemeData(
        color: iconColor ?? AppColors.background,
      ),
      leading: leading,
      actions: actions,
      bottom: bottom,
      title: Text(
        title,
        style: titleStyle ??
            TextStyle(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(20),
            ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
