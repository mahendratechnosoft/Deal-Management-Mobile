import 'package:flutter/material.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/task_module/create_task/screens/create_task_screen.dart';
import '../../edit_task/model/get_task_model.dart';

/// ---------------- TASK INFO CARD ----------------

class TaskInformationCard extends StatelessWidget {
  final Task task;
  const TaskInformationCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Information',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Start Date',
                  value: formatDate(task.startDate),
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Due Date',
                  value: formatDate(task.endDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Hourly Rate',
                  value: task.hourlyRate.toString(),
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Estimate',
                  value: task.estimatedHours.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            task.description.isEmpty
                ? 'No description provided'
                : task.description,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Text(
            'Related To',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            '${task.relatedTo} - ${task.relatedToName}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ACTION CARD ----------------
/// ---------------- ACTION CARD ----------------

class TaskActionCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final String name;
  final String label;
  final List<DropdownItem> items;
  final String selectedId;
  final bool edit;
  final Function(DropdownItem) onChanged;

  const TaskActionCard({
    super.key,
    required this.title,
    required this.edit,
    required this.name,
    required this.emptyText,
    required this.label,
    required this.items,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Find the currently selected value
    DropdownItem? currentValue;
    if (selectedId.isNotEmpty) {
      try {
        currentValue = items.firstWhere((e) => e.id == selectedId);
      } catch (e) {
        currentValue = null;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomDropdown<DropdownItem>(
            showLabel: true,
            labelText: label,
            enabled: edit,
            items: items,
            value: currentValue, // Use the found value or null
            onChanged: (value) {
              if (value != null && value.id.isNotEmpty) {
                onChanged(value);
              }
            },
            itemLabel: (item) => item.name,
          ),
        ],
      ),
    );
  }
}/// ---------------- HELPERS ----------------

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  );
}
