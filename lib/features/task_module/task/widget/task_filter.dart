import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_state.dart';

class TaskFilterBar extends StatelessWidget {
  final TaskFilter filter;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onPriority;

  const TaskFilterBar({
    super.key,
    required this.filter,
    required this.onSearch,
    required this.onStatus,
    required this.onPriority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          /// 🔍 Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: onSearch,
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: _FilterDropdown(
                  value: filter.status,
                  items: taskStatusList,
                  icon: Icons.flag,
                  onChanged: onStatus,
                ),
              ),
            ],
          ),

          //  const SizedBox(height: 10),

          /// 🎯 Filters
        ],
      ),
    );
  }
}

const List<Map<String, String>> taskStatusList = [
  {'label': 'All', 'value': 'All'},
  {'label': 'Not Started', 'value': 'NOT_STARTED'},
  {'label': 'In Progress', 'value': 'IN_PROGRESS'},
  {'label': 'Testing', 'value': 'TESTING'},
  {'label': 'Completed', 'value': 'COMPLETED'},
];

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<Map<String, String>> items;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'], // ✅ API value
              child: Row(
                children: [
                  Icon(icon, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    item['label']!, // ✅ UI label
                    style: TextStyle(fontSize: Responsive.sp(14)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}
