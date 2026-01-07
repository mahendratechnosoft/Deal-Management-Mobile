import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/drawer/presentation/header_widget.dart';
import 'app_drawer.dart';
import 'drawer_footer.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.h(260),
      decoration: const BoxDecoration(gradient: AppColors.drawerColor),
      child: SafeArea(
        child: Column(
          children: const [
            DrawerHeaderWidget(),
            DrawerMenu(),
            DrawerFooter(),
          ],
        ),
      ),
    );
  }
}
