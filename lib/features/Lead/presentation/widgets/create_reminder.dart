import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Create Reminder'),
      body: BlocConsumer<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is AllLeadState &&
              state.createReminder == false &&
              state.createReminderError == null) {
            Navigator.pop(context);
          }

          if (state is AllLeadState && state.createReminderError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.createReminderError!),
              ),
            );
          }
        },
        builder: (context, leadState) {
          return BlocBuilder<CreateTaskBloc, CreateTaskState>(
            builder: (context, createState) {
              return ListView(
                children: [
                  _leadInfoCard(),
                  _formCard(context, createState),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Button(
                      text: 'Create Reminder',
                      isLoading:
                          leadState is AllLeadState && leadState.createReminder,
                      onPressed: () {
                        if (triggerTime == null ||
                            createState.assignIdValue.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                            ),
                          );
                          return;
                        }

                        final request = CreateReminderRequest(
                          customerName: widget.lead.lead.clientName,
                          message: messageController.text,
                          triggerTime: triggerTime!,
                          relatedModule: 'LEAD',
                          referenceId: widget.lead.lead.id,
                          referenceName: widget.lead.lead.companyName,
                          sendEmailToCustomer: false,
                          repeatDays: 0,
                          recursionLimit: 0,
                          recurring:
                              reminderType.value == ReminderType.recurring,
                          employeeId: createState.assignIdValue,
                        );
                        log('Create Reminder Payload: ${request.toJson()}');
                        context
                            .read<LeadBloc>()
                            .add(CreateReminderSubmitEvent(request: request));
                        //    log('Payload : ${request.toJson()}');
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// ================= LEAD INFO =================

  Widget _leadInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _row(
            'Module',
            widget.reminders.isNotEmpty
                ? widget.reminders.first.relatedModule
                : 'LEAD',
            isChip: true,
          ),
          const SizedBox(height: 8),
          _row('Reference', widget.lead.lead.companyName),
          const SizedBox(height: 8),
          _row('Customer', widget.lead.lead.clientName),
        ],
      ),
    );
  }

  /// ================= FORM =================

  Widget _formCard(BuildContext context, CreateTaskState state) {
    final assignees = [
      DropdownItem(id: '', name: 'Select Assign'),
      ...state.assigneesList.map(
        (e) => DropdownItem(
          id: e.employeeId,
          name: e.name,
        ),
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDatePicker(
            showLabel: true,
            labelText: 'Trigger Time',
            hintText: 'Select Date',
            onDateSelected: (date) {
              triggerTime = date;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: messageController,
            hint: 'Enter reminder message',
            maxLines: 4,
            labelText: 'Message',
            showLabel: true,
          ),
          const SizedBox(height: 16),
          CustomDropdown<DropdownItem>(
            showLabel: true,
            labelText: 'Assignees',
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
          Text(
            'Reminder Type',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _reminderTypeButtons(),
          _recurringSection(),
        ],
      ),
    );
  }

  /// ================= REMINDER TYPE =================

  Widget _reminderTypeButtons() {
    return ValueListenableBuilder<ReminderType>(
      valueListenable: reminderType,
      builder: (context, type, _) {
        return Row(
          children: [
            Expanded(
              child: Button(
                text: 'One-Time',
                //    isSelected: type == ReminderType.oneTime,
                onPressed: () {
                  reminderType.value = ReminderType.oneTime;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Button(
                text: 'Recurring',
                //   isSelected: type == ReminderType.recurring,
                onPressed: () {
                  reminderType.value = ReminderType.recurring;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _recurringSection() {
    return ValueListenableBuilder<ReminderType>(
      valueListenable: reminderType,
      builder: (context, type, _) {
        if (type != ReminderType.recurring) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            CustomDropdown(
              showLabel: true,
              labelText: 'Repeat Every',
              items: [
                '1 Day',
                '1 Week',
                '1 Month',
                'Quartely',
                '6 Month',
                '1 Year'
              ],
              onChanged: (_) {},
              itemLabel: (v) => v,
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              showLabel: true,
              labelText: 'Recursion Limit',
              items: [
                '1 Time',
                '2 Time',
                '3 Time',
                '4 Time',
                '5 Time',
                '10 Times',
                'Unlimited',
              ],
              onChanged: (_) {},
              itemLabel: (v) => v,
            ),
          ],
        );
      },
    );
  }

  /// ================= HELPERS =================

  Widget _row(String label, String value, {bool isChip = false}) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        isChip
            ? Chip(label: Text(value))
            : Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    );
  }
}
