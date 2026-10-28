import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/drawer/presentation/header_widget.dart';
import 'app_drawer.dart';
import 'drawer_footer.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.h(255),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF111827), // Deep Charcoal (Gray 900)
            Color(0xFF1E293B), // Dark Slate (Slate 800)
          ],
        ),
        border: Border(
          right: BorderSide(
            color: Color(0xFF334155),
            width: 0.8,
          ),
        ),
      ),
      child: const SafeArea(
        child: Column(
          children: [
            DrawerHeaderWidget(),
            DrawerMenu(),
            DrawerFooter(),
          ],
        ),
      ),
    );
  }
}
