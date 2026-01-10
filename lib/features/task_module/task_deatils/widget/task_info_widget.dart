import 'package:flutter/material.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';

class TaskInformationCard extends StatelessWidget {
  const TaskInformationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          const Text(
            'Task Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Divider(height: 24),

          /// DATES
          Row(
            children: const [
              Expanded(
                child: _InfoItem(
                  label: 'Start Date',
                  value: '09/01/2026',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Due Date',
                  value: '09/01/2026',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// RATE & ESTIMATE
          Row(
            children: const [
              Expanded(
                child: _InfoItem(
                  label: 'Hourly Rate',
                  value: '0.00',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Estimate',
                  value: '0 hours',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// CREATED BY
          const Text(
            'Created by',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blue,
                child: Text(
                  'GD',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Ganesh Devkar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// DESCRIPTION
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'No description provided for this task',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TaskActionCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final String label;

  const TaskActionCard({
    super.key,
    required this.title,
    required this.emptyText,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptyText,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          CommonDropdown<String>(
            hintText: label,
            items: const [
              'A',
              'B',
              'C',
              'D',
            ],
            onChanged: (value) {},
          ),
        ],
      ),
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
