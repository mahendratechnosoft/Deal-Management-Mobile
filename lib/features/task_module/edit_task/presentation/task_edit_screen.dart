import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';
import '../../../../core/widgtes/app_snackbar.dart';

class EditTask extends StatefulWidget {
  const EditTask({super.key});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final subjectController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final estimateHoursController = TextEditingController();
  final descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskId = GoRouterState.of(context).extra as String;
      context.read<CreateTaskBloc>().add(GetTaskEvent(taskId: taskId));
      context.read<CreateTaskBloc>().add(LoadAssigneesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Edit Task'),
      body: SafeArea(
        minimum: const EdgeInsets.all(10),
        child: BlocListener<CreateTaskBloc, CreateTaskState>(
          listener: (context, state) {
            if (state.taskUpdated) {
              AppSnackBar.show(
                type: SnackBarType.success,
                context,
                message: 'Task updated successfully',
              );
              context.pop(true);
            }

            if (state.errorMessage != null) {
              AppSnackBar.show(
                type: SnackBarType.error,
                context,
                message: state.errorMessage!,
              );
            }

            if (state.getTaskModel != null) {
              final task = state.getTaskModel!.task;
              subjectController.text = task.subject;
              hourlyRateController.text = task.hourlyRate.toString();
              estimateHoursController.text = task.estimatedHours.toString();
              descriptionController.text = task.description;

              context.read<CreateTaskBloc>()
                ..add(TaskStartDateChanged(task.startDate))
                ..add(TaskDueDateChanged(task.endDate));
            }
          },
          child: BlocBuilder<CreateTaskBloc, CreateTaskState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              /// 🔹 Employee list for Assignee / Follower
              final employeeDropdownItems = [
                DropdownItem(id: '', name: 'Select'),
                ...state.assigneesList.map(
                  (e) => DropdownItem(
                    id: e.employeeId,
                    name: e.name,
                  ),
                ),
              ];

              /// 🔹 Related-to dropdown items
              final relatedItems = [
                DropdownItem(id: '', name: 'Non selected'),
                ...getAssigneeItems(state),
              ];

              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      'Fill in the task information below',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: Responsive.sp(14),
                      ),
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: 'Subject',
                      controller: subjectController,
                      showLabel: true,
                      labelText: 'Subject',
                      validator: (v) => Validators.required(v, 'Subject'),
                      isRequired: true,
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: '0:00',
                      controller: hourlyRateController,
                      keyboardType: TextInputType.number,
                      labelText: 'Hourly Rate',
                      showLabel: true,
                    ),
                    const SizedBox(height: 15),

                    /// START & DUE DATE
                    Row(
                      children: [
                        Expanded(
                          child: CustomDatePicker(
                            hintText: 'Start Date',
                            showLabel: true,
                            labelText: 'Start Date',
                            isRequired: true,
                            selectedDate: state.startDate,
                            errorText: 'Date is required',
                            onDateSelected: (date) {
                              startDate = date;
                              context
                                  .read<CreateTaskBloc>()
                                  .add(TaskStartDateChanged(date));
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: CustomDatePicker(
                            hintText: 'Due Date',
                            showLabel: true,
                            labelText: 'Due Date',
                            isRequired: true,
                            selectedDate: state.dueDate,
                            errorText: 'Date is required',
                            onDateSelected: (date) {
                              endDate = date;
                              context
                                  .read<CreateTaskBloc>()
                                  .add(TaskDueDateChanged(date));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    /// RELATED TO
                    CustomDropdown<String>(
                      showLabel: true,
                      labelText: 'Related To',
                      items: const [
                        'Non selected',
                        'Lead',
                        'Customer',
                        'Proposal',
                        'Proforma',
                        'Invoice'
                      ],
                      value: state.relatedTo,
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(RelatedChange(value));
                        }
                      },
                      itemLabel: (item) => item,
                    ),
                    const SizedBox(height: 15),

                    /// RELATED ITEM
                    CustomDropdown<DropdownItem>(
                      showLabel: true,
                      labelText: 'Select ${state.relatedTo}',
                      items: relatedItems,
                      value: relatedItems.firstWhere(
                        (e) => e.id == state.assignee,
                        orElse: () => relatedItems.first,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(DependsLelatedtoEvent(value));
                        }
                      },
                      itemLabel: (item) => item.name,
                    ),
                    const SizedBox(height: 15),

                    /// ASSIGNEE
                    CustomDropdown<DropdownItem>(
                      showLabel: true,
                      labelText: 'Assignee',
                      items: employeeDropdownItems,
                      value: state.assignIdValue.isEmpty
                          ? employeeDropdownItems.first
                          : employeeDropdownItems.firstWhere(
                              (e) => e.id == state.assignIdValue,
                              orElse: () => employeeDropdownItems.first,
                            ),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<CreateTaskBloc>().add(
                                AssigneesDropDownEvent(
                                  id: value.id,
                                  name: value.name,
                                ),
                              );
                        }
                      },
                      itemLabel: (item) => item.name,
                    ),
                    const SizedBox(height: 15),

                    /// FOLLOWER ✅
                    CustomDropdown<DropdownItem>(
                      showLabel: true,
                      labelText: 'Follower',
                      items: employeeDropdownItems,
                      value: state.followerId.isEmpty
                          ? employeeDropdownItems.first
                          : employeeDropdownItems.firstWhere(
                              (e) => e.id == state.followerId,
                              orElse: () => employeeDropdownItems.first,
                            ),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<CreateTaskBloc>().add(
                                FollowerChange(
                                  value.name,
                                  value.id,
                                ),
                              );
                        }
                      },
                      itemLabel: (item) => item.name,
                    ),
                    const SizedBox(height: 15),

                    /// PRIORITY
                    CustomDropdown<String>(
                      showLabel: true,
                      labelText: 'Priority',
                      items: const [
                        'Non selected',
                        'Low',
                        'Medium',
                        'High',
                        'Urgent',
                      ],
                      value: state.priority,
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(PriorityChange(value));
                        }
                      },
                      itemLabel: (item) => item,
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: '0:00',
                      controller: estimateHoursController,
                      keyboardType: TextInputType.number,
                      labelText: 'Estimate hours',
                      showLabel: true,
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: 'Add Description',
                      controller: descriptionController,
                      maxLines: 4,
                      labelText: 'Task Description',
                      showLabel: true,
                    ),
                    const SizedBox(height: 20),

                    Button(
                      text: 'Update Task',
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        final task = state.getTaskModel!.task;

                        final payload = TaskUpdateRequest(
                          taskId: task.taskId,
                          adminId: task.adminId,
                          subject: subjectController.text.trim(),
                          startDate: formatDate(startDate ?? state.startDate),
                          endDate: formatDate(endDate ?? state.dueDate),
                          priority: state.priority,
                          relatedTo: state.relatedTo,
                          relatedToId: task.relatedToId,
                          relatedToName: task.relatedToName,
                          hourlyRate:
                              double.tryParse(hourlyRateController.text) ?? 0,
                          estimatedHours:
                              double.tryParse(estimateHoursController.text) ??
                                  0,
                          description: descriptionController.text.trim(),
                          status: task.status,
                          assignedEmployees: [
                            Employee(
                              employeeId: state.assignIdValue,
                              name: state.assignNameValue,
                            ),
                          ],
                          followersEmployees: state.followerId.isEmpty
                              ? []
                              : [
                                  Employee(
                                    employeeId: state.followerId,
                                    name: state.followerName,
                                  ),
                                ],
                          createdAt: task.createdAt,
                          createdBy: task.createdBy,
                          employeeId: '',
                        );

                        context.read<CreateTaskBloc>().add(
                              UpdateTaskEvent(request: payload),
                            );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Utils
String formatDate(DateTime? date) {
  if (date == null) return '';
  return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";
}

List<DropdownItem> getAssigneeItems(CreateTaskState state) {
  switch (state.relatedTo) {
    case 'Lead':
      return state.leadList
          .where((e) => e.clientName.isNotEmpty)
          .map((e) => DropdownItem(id: e.leadId, name: e.clientName))
          .toList();
    case 'Customer':
      return state.customerList
          .where((e) => e.companyName.isNotEmpty)
          .map((e) => DropdownItem(id: e.id, name: e.companyName))
          .toList();
    case 'Proforma':
      return state.proformList
          .where((e) => e.formatedProformaInvoiceNumber.isNotEmpty)
          .map((e) => DropdownItem(
              id: e.proformaInvoiceId, name: e.formatedProformaInvoiceNumber))
          .toList();
    case 'Proposal':
      return state.proposalList
          .where((e) => e.formatedProposalNumber.isNotEmpty)
          .map((e) =>
              DropdownItem(id: e.proposalId, name: e.formatedProposalNumber))
          .toList();
    case 'Invoice':
      return state.invoiceList
          .where((e) => e.formatedInvoiceNumber.isNotEmpty)
          .map((e) =>
              DropdownItem(id: e.invoiceId, name: e.formatedInvoiceNumber))
          .toList();
    default:
      return [];
  }
}
