import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/create_task/model/time_detail_model.dart';

void showTimeLogsDialog(BuildContext context, CreateTaskState state) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: AppColors.background,
        elevation: 8,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader(context),
              _summarySection(state.timeDetailsModel),
              const Divider(height: 1),

              /// SMART LIST
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.timeDetailsModel.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = state.timeDetailsModel[index];
                    return _timeLogTile(item);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ---------------- HEADER ----------------
Widget _dialogHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    child: Row(
      children: [
        const Text(
          'Time Logs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

/// ---------------- SUMMARY (DYNAMIC) ----------------
Widget _summarySection(List<TimeDetailsModel> logs) {
  final totalMinutes = logs.fold<int>(0, (sum, e) => sum + e.durationInMinutes);

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  final totalTime = '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Total Time',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            totalTime,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

/// ---------------- LOG TILE (DYNAMIC) ----------------
Widget _timeLogTile(TimeDetailsModel snap) {
  final initials = snap.name.isNotEmpty
      ? snap.name
          .trim()
          .split(' ')
          .map((e) => e[0])
          .take(2)
          .join()
          .toUpperCase()
      : 'NA';

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderDark),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// AVATAR
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 12),

        /// CONTENT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// NAME + DURATION
              Row(
                children: [
                  Text(
                    snap.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      '${snap.durationInMinutes} min',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),

              // const SizedBox(height: 8),
              _logInfoRow(
                'Note',
                snap.endNote,
              ),
              _logInfoRow(
                'Start',
                _formatDateTime(snap.startTime),
              ),
              _logInfoRow(
                'End',
                _formatDateTime(snap.endTime),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ---------------- INFO ROW ----------------
Widget _logInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

/// ---------------- DATE FORMATTER ----------------
String _formatDateTime(DateTime dt) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';

  return '${dt.day.toString().padLeft(2, '0')} '
      '${months[dt.month - 1]} ${dt.year} · '
      '$hour:$minute $amPm';
}
