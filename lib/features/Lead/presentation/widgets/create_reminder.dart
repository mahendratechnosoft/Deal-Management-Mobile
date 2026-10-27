import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/create_reminder_payload.dart';
import 'package:xpertbiz/features/Lead/data/model/lead_details_model.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import '../../data/model/reminder_model.dart';

enum ReminderType { oneTime, recurring }

class CreateReminder extends StatefulWidget {
  final List<ReminderModel> reminders;
  final LeadDetailsModel lead;

  const CreateReminder({
    super.key,
    required this.reminders,
    required this.lead,
  });

  @override
  State<CreateReminder> createState() => _CreateReminderState();
}

class _CreateReminderState extends State<CreateReminder> {
  @override
  void initState() {
    context.read<CreateTaskBloc>().add(LoadAssigneesEvent());
    super.initState();
  }

  final ValueNotifier<ReminderType> reminderType =
      ValueNotifier(ReminderType.oneTime);

  final messageController = TextEditingController();
  DateTime? triggerTime;

  @override
  void dispose() {
    messageController.dispose();
    reminderType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(title: 'Create Reminder'),
      body: BlocConsumer<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is AllLeadState &&
              state.createReminder == false &&
              state.createReminderError == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder created successfully!'),
                backgroundColor: Color(0xFF059669),
              ),
            );
            Navigator.pop(context);
          }

          if (state is AllLeadState && state.createReminderError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.createReminderError!),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }
        },
        builder: (context, leadState) {
          return BlocBuilder<CreateTaskBloc, CreateTaskState>(
            builder: (context, createState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    _buildLeadSummaryCard(),
                    const SizedBox(height: 16),
                    _buildFormCard(context, createState),
                    const SizedBox(height: 24),
                    _buildSubmitButton(leadState, createState),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ================= LEAD SUMMARY CARD =================
  Widget _buildLeadSummaryCard() {
    final clientName = widget.lead.lead.clientName;
    final initials = clientName.trim().isNotEmpty
        ? clientName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName.isNotEmpty ? clientName : 'Unnamed Client',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (widget.lead.lead.companyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.lead.lead.companyName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'LEAD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= FORM CARD =================
  Widget _buildFormCard(BuildContext context, CreateTaskState state) {
    final assignees = [
      DropdownItem(id: '', name: 'Select Assignee'),
      ...state.assigneesList.map(
        (e) => DropdownItem(
          id: e.employeeId,
          name: e.name,
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reminder Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          CustomDatePicker(
            showLabel: true,
            labelText: 'Trigger Date & Time',
            isRequired: true,
            hintText: 'Select Date & Time',
            onDateSelected: (date) {
              triggerTime = date;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: messageController,
            hint: 'What should you be reminded about? e.g. Call regarding quotation...',
            maxLines: 3,
            labelText: 'Reminder Message',
            showLabel: true,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          CustomDropdown<DropdownItem>(
            showLabel: true,
            labelText: 'Assign To',
            items: assignees,
            value: state.assignIdValue.isEmpty
                ? assignees.first
                : assignees.firstWhere(
                    (e) => e.id == state.assignIdValue,
                    orElse: () => assignees.first,
                  ),
            onChanged: (value) {
              if (value == null) return;
              context.read<CreateTaskBloc>().add(
                    AssigneesDropDownEvent(
                      id: value.id,
                      name: value.name,
                    ),
                  );
            },
            itemLabel: (item) => item.name,
          ),
          const SizedBox(height: 20),
          const Text(
            'Reminder Frequency',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          _buildSegmentedTypeButtons(),
          _buildRecurringSection(),
        ],
      ),
    );
  }

  /// ================= SEGMENTED REMINDER TYPE =================
  Widget _buildSegmentedTypeButtons() {
    return ValueListenableBuilder<ReminderType>(
      valueListenable: reminderType,
      builder: (context, type, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _typeTabItem(
                  title: 'One-Time',
                  icon: Icons.event_available_rounded,
                  isSelected: type == ReminderType.oneTime,
                  onTap: () => reminderType.value = ReminderType.oneTime,
                ),
              ),
              Expanded(
                child: _typeTabItem(
                  title: 'Recurring',
                  icon: Icons.repeat_rounded,
                  isSelected: type == ReminderType.recurring,
                  onTap: () => reminderType.value = ReminderType.recurring,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _typeTabItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSection() {
    return ValueListenableBuilder<ReminderType>(
      valueListenable: reminderType,
      builder: (context, type, _) {
        if (type != ReminderType.recurring) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              CustomDropdown<String>(
                showLabel: true,
                labelText: 'Repeat Interval',
                items: const [
                  '1 Day',
                  '1 Week',
                  '1 Month',
                  'Quarterly',
                  '6 Months',
                  '1 Year',
                ],
                onChanged: (_) {},
                itemLabel: (v) => v,
              ),
              const SizedBox(height: 14),
              CustomDropdown<String>(
                showLabel: true,
                labelText: 'Recursion Limit',
                items: const [
                  '1 Time',
                  '2 Times',
                  '3 Times',
                  '4 Times',
                  '5 Times',
                  '10 Times',
                  'Unlimited',
                ],
                onChanged: (_) {},
                itemLabel: (v) => v,
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= SUBMIT BUTTON =================
  Widget _buildSubmitButton(LeadState leadState, CreateTaskState createState) {
    final bool isSubmitting =
        leadState is AllLeadState && leadState.createReminder;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting
            ? null
            : () {
                if (triggerTime == null || createState.assignIdValue.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select trigger date and assignee'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }

                if (messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reminder message'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }

                final request = CreateReminderRequest(
                  customerName: widget.lead.lead.clientName,
                  message: messageController.text.trim(),
                  triggerTime: triggerTime!,
                  relatedModule: 'LEAD',
                  referenceId: widget.lead.lead.id,
                  referenceName: widget.lead.lead.companyName,
                  sendEmailToCustomer: false,
                  repeatDays: 0,
                  recursionLimit: 0,
                  recurring: reminderType.value == ReminderType.recurring,
                  employeeId: createState.assignIdValue,
                );
                log('Create Reminder Payload: ${request.toJson()}');
                context
                    .read<LeadBloc>()
                    .add(CreateReminderSubmitEvent(request: request));
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          disabledBackgroundColor: const Color(0xFF93C5FD),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_alarm_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Create Reminder',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
