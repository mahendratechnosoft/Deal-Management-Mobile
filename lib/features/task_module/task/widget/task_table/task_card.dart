import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String startDate;
  final String endDate;
  final String assignee;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? enable;

  const TaskCard({
    super.key,
    required this.title,
    required this.id,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.assignee,
    this.onEdit,
    this.enable,
    this.onDelete,
  });

  // ---------------- COLORS ----------------

  Color getStatusColor() {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF15803D);
      case 'Testing':
        return const Color(0xFFB45309);
      case 'Not Started':
        return const Color(0xFF475569);
      default:
        return const Color(0xFF475569);
    }
  }

  Color getStatusBg() {
    switch (status) {
      case 'In Progress':
        return const Color(0xFFDBEAFE);
      case 'Completed':
        return const Color(0xFFDCFCE7);
      case 'Testing':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color getPriorityColor() {
    switch (priority) {
      case 'High':
        return const Color(0xFFDC2626);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF16A34A);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final bool overdue = isOverdue(endDate);
    final Color statusColor = overdue ? Colors.red : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.5, color: getPriorityColor()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- TITLE + ACTIONS ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              //  Spacer(),
            ],
          ),

          const SizedBox(height: 10),

          /// ---------- STATUS + PRIORITY ----------
          Row(
            children: [
              _StatusChip(
                label: status,
                color: getStatusColor(),
                bgColor: getStatusBg(),
              ),
              Spacer(),
              _PriorityChip(
                label: priority,
                color: getPriorityColor(),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// ---------- DATES ----------
          Row(
            children: [
              const Icon(Icons.play_circle_outline,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                startDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 16),
              Spacer(),
              Icon(
                Icons.stop_circle_outlined,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                endDate,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: overdue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// ---------- ASSIGNEE ----------
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFDBEAFE),
                child: Text(
                  assignee.isNotEmpty ? assignee[0].toUpperCase() : "?",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                assignee,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
              enable == true
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                      onPressed: onDelete,
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;

  const _PriorityChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

bool isOverdue(String endDate) {
  // 🔒 Trim string (VERY IMPORTANT)
  final cleaned = endDate.trim();

  final formatter = DateFormat('dd MMM yyyy', 'en_US');

  // 🔒 Parse end date and strip time
  final parsed = formatter.parseStrict(cleaned);
  final end = DateTime(parsed.year, parsed.month, parsed.day);

  // 🔒 Strip time from today
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 🔴 Red ONLY after end date
  return today.isAfter(end);
}
