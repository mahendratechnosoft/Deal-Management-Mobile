import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import '../../create_task/model/assign_model.dart';

String statusLable(String? apiStatus) {
  if (apiStatus == null) return 'Not started';
  return taskStatusMap[apiStatus] ?? 'Not_started';
}

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

String formater(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;

  return '${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}:'
      '${s.toString().padLeft(2, '0')}';
}

Widget assigneeRow({
  required DropdownItem item,
  required VoidCallback onRemove,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        /// Avatar (Initials)
        Chip(
          backgroundColor: AppColors.primaryDark,
          label: Text(
            _getInitials(item.name),
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.sp(8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 5),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onRemove,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.red.shade400,
            ),
          ),
        ),
      ],
    ),
  );
}

String _getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length == 1) {
    return name;
  }
  return name;
}

const Map<String, String> taskStatusMap = {
  'NOT_STARTED': 'Not started',
  'IN_PROGRESS': 'In progress',
  'TESTING': 'Testing',
  'AWAITING_FEEDBACK': 'Awaiting Feedback',
  'COMPLETE': 'Complete',
};

List<DropdownItem> buildAssigneeDropdownItems({
  required List<AssignModel> allItems,
  required List<DropdownItem> selectedAssignees,
  required List<DropdownItem> selectedFollowers,
}) {
  return allItems
      .where(
    (a) => !selectedFollowers.any((f) => f.id == a.employeeId),
  )
      .map((a) {
    final isSelected = selectedAssignees.any((s) => s.id == a.employeeId);

    return DropdownItem(
      id: a.employeeId,
      name: isSelected ? '${a.name} ✓' : a.name,
      displayName: isSelected ? '${a.name} ✓' : a.name,
      isSelected: isSelected,
    );
  }).toList();
}

List<DropdownItem> buildFollowerDropdownItems({
  required List<AssignModel> allItems,
  required List<DropdownItem> selectedFollowers,
  required List<DropdownItem> selectedAssignees,
}) {
  return allItems
      .where(
    (a) => !selectedAssignees.any((s) => s.id == a.employeeId),
  )
      .map((a) {
    final isSelected = selectedFollowers.any((s) => s.id == a.employeeId);

    return DropdownItem(
      id: a.employeeId,
      name: isSelected ? '${a.name} ✓' : a.name,
      displayName: isSelected ? '${a.name} ✓' : a.name,
      isSelected: isSelected,
    );
  }).toList();
}
