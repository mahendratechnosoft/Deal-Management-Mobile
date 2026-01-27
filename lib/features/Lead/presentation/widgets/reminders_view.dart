import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/Lead/data/model/lead_details_model.dart';
import 'package:xpertbiz/features/Lead/data/model/reminder_model.dart';

class RemindersView extends StatelessWidget {
  final List<ReminderModel> reminders;
  final bool isLoading;
  final LeadDetailsModel lead;
  const RemindersView({
    super.key,
    required this.reminders,
    this.isLoading = false,
    required this.lead,
  });

  @override
  Widget build(BuildContext context) {
    log('build');
    return Scaffold(
      backgroundColor: AppColors.background,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primaryDark,
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(
      //         builder: (context) => CreateReminder(
      //               reminders: reminders,
      //               lead: lead,
      //             )));
      //   },
      //   child: Icon(
      //     Icons.add,
      //     color: AppColors.background,
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isLoading
                  ? _skeletonList()
                  : reminders.isEmpty
                      ? _emptyState()
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 15),
                          itemCount: reminders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reminder = reminders[index];
                            return _swipeCard(
                              context,
                              reminder,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swipeCard(BuildContext context, ReminderModel reminder) {
    return Dismissible(
      key: ValueKey(reminder.reminderId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Delete',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      confirmDismiss: (_) async {
        return await _confirmDelete(context);
      },
      onDismissed: (_) {},
      child: _reminderCard(context, reminder),
    );
  }

  /// ================= REMINDER CARD =================

  Widget _reminderCard(BuildContext context, ReminderModel reminder) {
    final bool isOverdue =
        !reminder.sent && reminder.triggerTime.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue ? Colors.red : Colors.grey.shade300,
          width: isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CUSTOMER + STATUS
          Row(
            children: [
              Expanded(
                child: Text(
                  reminder.customerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _statusChip(reminder),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            reminder.referenceName,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          /// MESSAGE
          _labelValue('Message', reminder.message),

          const SizedBox(height: 10),

          /// TRIGGER TIME
          Row(
            children: [
              _labelValue(
                'Trigger Time',
                _formatDate(reminder.triggerTime),
                highlight: isOverdue,
              ),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.edit_square))
            ],
          ),
        ],
      ),
    );
  }

  /// ================= LABEL VALUE =================

  Widget _labelValue(
    String label,
    String value, {
    bool highlight = false,
  }) {
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
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: highlight ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  /// ================= STATUS CHIP =================

  Widget _statusChip(ReminderModel reminder) {
    final pending = !reminder.sent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pending ? Colors.blue.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        pending ? 'Pending' : 'Sent',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: pending ? Colors.blue : Colors.green,
        ),
      ),
    );
  }

  Widget _skeletonList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'No reminders found',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  /// ================= HELPERS =================

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Reminder'),
            content:
                const Text('Are you sure you want to delete this reminder?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
