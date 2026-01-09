import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';

class TaskDetails extends StatelessWidget {
  const TaskDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        iconTheme: IconThemeData(color: AppColors.background),
        title: Text(
          "Task Details",
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
            fontSize: Responsive.sp(20),
          ),
        ),
      ),
    );
  }
}
