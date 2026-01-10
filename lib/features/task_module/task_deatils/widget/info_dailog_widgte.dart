import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';

void showTimeLogsDialog(BuildContext context) {
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
            mainAxisSize: MainAxisSize.min, // ✅ shrink when possible
            children: [
              _dialogHeader(context),
              _summarySection(),
              const Divider(height: 1),

              /// SMART LIST
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true, // ✅ key point
                  padding: const EdgeInsets.all(16),
                  itemCount: 2, // change dynamically
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _timeLogTile(),
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

/// ---------------- SUMMARY ----------------
Widget _summarySection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Row(
        children: const [
          Icon(Icons.timer_outlined, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'Total Time',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          Text(
            '02:45:30',
            style: TextStyle(
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

/// ---------------- LOG TILE ----------------
Widget _timeLogTile() {
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
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue,
          child: Text(
            'GD',
            style: TextStyle(
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
                children: const [
                  Text(
                    'Ganesh Devkar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      '45 min',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _logInfoRow('Start', '09 Jan 2026 · 10:00 AM'),
              _logInfoRow('End', '09 Jan 2026 · 10:45 AM'),
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
