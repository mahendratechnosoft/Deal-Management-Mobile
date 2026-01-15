import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/create_task/model/assign_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';
import 'package:xpertbiz/features/task_module/task_deatils/screen/task_details_screen.dart';
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
  late bool isEditRestricted;
  late String currentUserRole;

  @override
  void initState() {
    super.initState();

    // Get current user role
    final user = AuthLocalStorage.getUser();
    currentUserRole = user?.role ?? '';

    // Check if edit is restricted for this role
    isEditRestricted = RoleResolver.isEmployeeRestricted(currentUserRole);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskId = GoRouterState.of(context).extra as String;
      context.read<CreateTaskBloc>().add(GetTaskEvent(taskId: taskId));

      // Only load assignees if user has permission to edit
      if (!isEditRestricted) {
        context.read<CreateTaskBloc>().add(LoadAssigneesEvent());
      }
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
              GoRouter.of(context).pop(true);
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
              if (state.isLoading || state.getTaskModel == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final task = state.getTaskModel!.task;
              final edit = state.getTaskModel!.canEdit;
              isEditRestricted = !edit;

              /// 🔹 MASTER EMPLOYEE LIST
              final allEmployees = state.assigneesList;

              final relatedItems = [
                DropdownItem(id: '', name: task.relatedToName),
                ...getAssigneeItems(state),
              ];

              /// 🔹 ASSIGNEE LIST (exclude follower)
              final assigneList = buildEmployeeDropdown(
                allEmployees: allEmployees,
                excludeEmployeeId: state.followerId,
                placeholder: task.assignedEmployees.isNotEmpty
                    ? task.assignedEmployees.first.name
                    : 'Select Assignee',
              );

              /// 🔹 FOLLOWER LIST (exclude assignee)
              final followerList = buildEmployeeDropdown(
                allEmployees: allEmployees,
                excludeEmployeeId: state.assignIdValue,
                placeholder: task.followersEmployees.isNotEmpty
                    ? task.followersEmployees.first.name
                    : 'Select Follower',
              );

              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    isEditRestricted
                        ? SizedBox.shrink()
                        : Text(
                            'Fill in the task information below',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: Responsive.sp(14),
                            ),
                          ),
                    const SizedBox(height: 15),

                    /// Restriction Warning Message
                    if (isEditRestricted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.orange.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Access Restricted',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You do not have permission to update this task. You can only view the information.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    AppTextField(
                      hint: 'Subject',
                      controller: subjectController,
                      showLabel: true,
                      labelText: 'Subject',
                      validator: (v) => Validators.required(v, 'Subject'),
                      isRequired: true,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown<String>(
                            height: 57,
                            hintText: 'Status',
                            value: resolveStatusLabel(task.status),
                            items: taskStatusMap.values.toList(),
                            enabled: !isEditRestricted,
                            showLabel: true, // Add this
                            labelText: 'Status', // Add this
                            onChanged: (value) {
                              if (value == null) return;

                              final apiValue = taskStatusMap.entries
                                  .firstWhere((e) => e.value == value)
                                  .key;

                              context
                                  .read<CreateTaskBloc>()
                                  .add(StatusEvent(apiValue));
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            hint: '0:00',
                            controller: hourlyRateController,
                            keyboardType: TextInputType.number,
                            labelText: 'Hourly Rate',
                            showLabel: true,
                            enabled: !isEditRestricted,
                          ),
                        ),
                      ],
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
                            onDateSelected: !isEditRestricted
                                ? (date) {
                                    startDate = date;
                                    context
                                        .read<CreateTaskBloc>()
                                        .add(TaskStartDateChanged(date));
                                  }
                                : null, // Disable callback if restricted
                            enabled: !isEditRestricted, // Disable if restricted
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
                            onDateSelected: !isEditRestricted
                                ? (date) {
                                    endDate = date;
                                    context
                                        .read<CreateTaskBloc>()
                                        .add(TaskDueDateChanged(date));
                                  }
                                : null, // Disable callback if restricted
                            enabled: !isEditRestricted, // Disable if restricted
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
                      onChanged: !isEditRestricted
                          ? (value) {
                              if (value != null) {
                                context
                                    .read<CreateTaskBloc>()
                                    .add(RelatedChange(value));
                              }
                            }
                          : null, // Disable if restricted
                      itemLabel: (item) => item,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    //  const SizedBox(height: 15),
                    task.relatedTo == 'Non selected'
                        ? SizedBox.shrink()
                        : const SizedBox(height: 15),

                    task.relatedTo == 'Non selected'
                        ? SizedBox.shrink()
                        :

                        /// RELATED ITEM
                        CustomDropdown<DropdownItem>(
                            showLabel: true,
                            labelText: 'Select ${task.relatedTo}',
                            items: relatedItems,
                            value: relatedItems.firstWhere(
                              (e) => e.id == state.assignee,
                              orElse: () => relatedItems.first,
                            ),
                            onChanged: !isEditRestricted
                                ? (value) {
                                    if (value != null) {
                                      context
                                          .read<CreateTaskBloc>()
                                          .add(DependsLelatedtoEvent(value));
                                    }
                                  }
                                : null, // Disable if restricted
                            itemLabel: (item) => item.name,
                            enabled: !isEditRestricted, // Disable if restricted
                          ),
                    const SizedBox(height: 15),

                    /// ASSIGNEE
                    CustomDropdown<DropdownItem>(
                      showLabel: true,
                      labelText: 'Assignee',
                      items: assigneList,
                      value: state.assignIdValue.isEmpty
                          ? assigneList.first
                          : assigneList.firstWhere(
                              (e) => e.id == state.assignIdValue,
                              orElse: () => assigneList.first,
                            ),
                      onChanged: !isEditRestricted
                          ? (value) {
                              if (value == null) return;
                              context.read<CreateTaskBloc>().add(
                                    AssigneesDropDownEvent(
                                      id: value.id,
                                      name: value.name,
                                    ),
                                  );
                            }
                          : null, // Disable if restricted
                      itemLabel: (item) => item.name,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    const SizedBox(height: 15),

                    /// FOLLOWER
                    CustomDropdown<DropdownItem>(
                      showLabel: true,
                      labelText: 'Follower',
                      items: followerList,
                      value: state.followerId.isEmpty
                          ? followerList.first
                          : followerList.firstWhere(
                              (e) => e.id == state.followerId,
                              orElse: () => followerList.first,
                            ),
                      onChanged: !isEditRestricted
                          ? (value) {
                              if (value == null) return;
                              context.read<CreateTaskBloc>().add(
                                    FollowerChange(value.name, value.id),
                                  );
                            }
                          : null, // Disable if restricted
                      itemLabel: (item) => item.name,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    const SizedBox(height: 20),

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
                      value: task.priority,
                      onChanged: !isEditRestricted
                          ? (value) {
                              if (value != null) {
                                context
                                    .read<CreateTaskBloc>()
                                    .add(PriorityChange(value));
                              }
                            }
                          : null, // Disable if restricted
                      itemLabel: (item) => item,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: '0:00',
                      controller: estimateHoursController,
                      keyboardType: TextInputType.number,
                      labelText: 'Estimate hours',
                      showLabel: true,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: 'Add Description',
                      controller: descriptionController,
                      maxLines: 4,
                      labelText: 'Task Description',
                      showLabel: true,
                      enabled: !isEditRestricted, // Disable if restricted
                    ),
                    const SizedBox(height: 20),

                    /// UPDATE BUTTON or RESTRICTED MESSAGE
                    if (isEditRestricted)
                      SizedBox.shrink()
                    else
                      Button(
                        text: 'Update Task',
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          final task = state.getTaskModel!.task;
                          final user = AuthLocalStorage.getUser();
                          final time = DateTime.now();

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
                            status: state.status,
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
                            createdAt: time,
                            createdBy: user!.loginUserName ?? 'NA',
                            employeeId: user.employeeId ?? 'NA',
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

List<DropdownItem> buildEmployeeDropdown({
  required List<AssignModel> allEmployees,
  required String excludeEmployeeId,
  required String placeholder,
}) {
  return [
    DropdownItem(id: '', name: placeholder),
    ...allEmployees.where((e) => e.employeeId != excludeEmployeeId).map(
          (e) => DropdownItem(
            id: e.employeeId,
            name: e.name,
          ),
        ),
  ];
}
