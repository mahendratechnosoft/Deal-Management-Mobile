import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/info_dailog_widgte.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/statistics_widget.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/task_info_widget.dart';

class TaskDetails extends StatelessWidget {
  const TaskDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Task Details'),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(12),
        ),
        child: ListView(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// STATUS ROW
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CommonDropdown<String>(
                    hintText: 'Status',
                    value: 'Time Logs',
                    items: const [
                      'Time Logs',
                      'Statistics',
                      'Comments',
                      'Attchments',
                    ],
                    onChanged: (value) {
                      log('Status: $value');
                      if (value == 'Time Logs') {
                        showTimeLogsDialog(context);
                      } else if (value == 'Statistics') {
                        showWeeklyTimeDialog(context);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: CommonDropdown<String>(
                    hintText: 'Status',
                    value: 'In progress',
                    items: const [
                      'Not started',
                      'In progress',
                      'Testing',
                      'Complete',
                    ],
                    onChanged: (value) {
                      log('Selected: $value');
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(16)),

            /// TIME TRACKING CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      const Text(
                        'Test',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          log('start timer');
                        },
                        child: const Chip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.primary,
                          label: Text(
                            'Start',
                            style: TextStyle(
                                color: AppColors.background, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// TOTAL TIME
                  infoRow(
                    title: 'Time Tracking',
                    value: '00:45:07',
                  ),

                  const SizedBox(height: 8),

                  /// SESSION STATUS
                  Row(
                    children: const [
                      Text(
                        'Current session',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.radio_button_checked,
                        size: 12,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TaskInformationCard(),
            SizedBox(height: 16),
            TaskActionCard(
              title: 'Assignees',
              label: 'Add Assigness',
              emptyText: 'No assignees selected',
            ),
            SizedBox(height: 16),
            TaskActionCard(
              title: 'Followers',
              label: 'Add Followers',
              emptyText: 'No followers selected',
            ),
          ],
        ),
      ),
    );
  }

  /// REUSABLE ROW
  Widget infoRow({required String title, required String value}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
