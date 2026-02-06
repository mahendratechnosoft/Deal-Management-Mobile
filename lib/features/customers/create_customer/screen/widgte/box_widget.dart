import 'package:flutter/widgets.dart';
import '../../../../../core/utils/app_colors.dart';

Widget commonBox(BuildContext context, String title) {
  return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        color: AppColors.surfaceSoft,
      ),
      child: Text(
        textAlign: TextAlign.center,
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ));
}
