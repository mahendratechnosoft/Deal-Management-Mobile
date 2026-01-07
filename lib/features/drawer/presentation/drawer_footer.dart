import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';

import 'logout_dialog.dart';

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(12)),
      child: Column(
        children: [
          const Divider(
            thickness: 0.5,
            color: AppColors.textSecondary,
          ),
          // SizedBox(height: Responsive.h(8)),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: TextStyle(
                fontSize: Responsive.sp(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            ),
            onTap: () async {
              final bool? shouldLogout = await showLogoutDialog(context);
              if (shouldLogout == true) {
                AuthLocalStorage.clear();
                context.go(AppRouteName.login);
              }
            },
          ),
        ],
      ),
    );
  }
}
