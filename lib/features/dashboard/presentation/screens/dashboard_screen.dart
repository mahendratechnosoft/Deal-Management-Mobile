import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/dashboard/presentation/screens/notification_screen.dart';
import 'package:xpertbiz/features/drawer/presentation/custom_drawer.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final user = AuthLocalStorage.getUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        iconTheme: IconThemeData(color: AppColors.background),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
              },
              icon: Icon(Icons.notifications))
        ],
        title: Text(
          'Hello ${user?.loginEmail.split('@').first.replaceAll(RegExp(r'\d+'), '')}',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
            fontSize: Responsive.sp(20),
          ),
        ),
      ),
      body: const Center(
        child: Text('Welcome to the Dashboard!'),
      ),
    );
  }
}
