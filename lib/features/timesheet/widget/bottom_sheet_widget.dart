import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';

void showDayDetails(
  DateTime date,
  List<Attendance> records,
  BuildContext context,
) {
  showModalBottomSheet(
    backgroundColor: AppColors.background,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      final checkIns = records.where((e) => e.status).toList();
      final checkOuts = records.where((e) => !e.status).toList();

      DateTime? startTime = checkIns.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(
              checkIns.first.timeStamp,
            )
          : null;

      DateTime? endTime = checkOuts.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(
              checkOuts.last.timeStamp,
            )
          : null;

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.35,
        maxChildSize: 0.8,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== DRAG HANDLE =====
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ===== DATE =====
                Text(
                  _fmt(date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ===== SUMMARY =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryItem(
                        'Start',
                        startTime != null ? _formatTime(startTime) : '--',
                        Icons.login,
                        Colors.green,
                      ),
                      _summaryItem(
                        'End',
                        endTime != null ? _formatTime(endTime) : '--',
                        Icons.logout,
                        Colors.red,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Attendance Logs',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // ===== LOG LIST =====
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    itemCount: records.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade300),
                    itemBuilder: (_, index) {
                      final r = records[index];
                      final time =
                          DateTime.fromMillisecondsSinceEpoch(r.timeStamp);

                      final isCheckIn = r.status;

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isCheckIn
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            child: Icon(
                              isCheckIn ? Icons.login : Icons.logout,
                              size: 16,
                              color: isCheckIn ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isCheckIn ? 'Check In' : 'Check Out',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(time),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

String _formatTime(DateTime t) {
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

String _fmt(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

Widget _summaryItem(
  String label,
  String value,
  IconData icon,
  Color color,
) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}
