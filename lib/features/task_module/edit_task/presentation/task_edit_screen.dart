import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgtes/app_snackbar.dart';
import '../../../../core/widgtes/custom_dropdown.dart';
import 'task_edit_helper.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';
import 'package:xpertbiz/features/task_module/task_deatils/screen/helper_widget.dart';

class EditTask extends StatefulWidget {
  const EditTask({super.key});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  // bool isEditRestricted;
  bool isEdit = true;
  late String currentUserRole;
  final formKey = GlobalKey<FormState>();

  final subjectController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final estimateHoursController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = AuthLocalStorage.getUser();
    currentUserRole = user?.role ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskId = GoRouterState.of(context).extra as String;
      context.read<CreateTaskBloc>().add(GetTaskEvent(taskId: taskId));
    });
  }

  @override
  Widget build(BuildContext cnxt) {
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

              isEdit = state.getTaskModel!.canEdit;

              /// 🔹 MASTER EMPLOYEE LIST
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
              final allEmployees = state.assigneesList;

              final relatedItems = [
                DropdownItem(id: 'Select', name: task.relatedToName),
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
                key: formKey,
                child: ListView(
                  children: [
                    !isEdit
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
                    if (!isEdit)
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
                      enabled: !!isEdit, // Disable if restricted
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown<String>(
                            height: 57,
                            hintText: 'Status',
                            value: statusLable(task.status),
                            items: taskStatusMap.values.toList(),
                            enabled: !!isEdit,
                            showLabel: true, // Add this
                            labelText: 'Status', // Add this
                            onChanged: (value) {
                              if (value == null) return;

                              final apiValue = taskStatusMap.entries
                                  .firstWhere((e) => e.value == value)
                                  .key;

                              cnxt
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
                            enabled: !!isEdit,
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
                            onDateSelected: !!isEdit
                                ? (date) {
                                    //    startDate = date;
                                    cnxt
                                        .read<CreateTaskBloc>()
                                        .add(TaskStartDateChanged(date));
                                  }
                                : null,
                            enabled: !!isEdit,
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
                            onDateSelected: !!isEdit
                                ? (date) {
                                    //   endDate = date;
                                    cnxt
                                        .read<CreateTaskBloc>()
                                        .add(TaskDueDateChanged(date));
                                  }
                                : null,
                            enabled: !!isEdit,
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
                      validator: (value) {
                        if (value == null) {
                          return 'Related To is required';
                        }
                        return null;
                      },
                      onChanged: !!isEdit
                          ? (value) {
                              //  log('response ${state.relatedTo}');
                              if (value != null) {
                                cnxt.read<CreateTaskBloc>().add(RelatedChange(
                                      value,
                                    ));
                                cnxt
                                    .read<CreateTaskBloc>()
                                    .add(FetchListEvent(value: value));
                              }
                            }
                          : null,
                      itemLabel: (item) => item,
                    ),
                    state.relatedTo == 'Non selected'
                        ? SizedBox.shrink()
                        : const SizedBox(height: 15),

                    state.relatedTo == 'Non selected'
                        ? SizedBox.shrink()
                        : CustomDropdown<DropdownItem>(
                            showLabel: true,
                            labelText: state.relatedTo == 'Non selected'
                                ? 'Assignees'
                                : 'Select ${state.relatedTo}',
                            items: relatedItems,
                            value: relatedItems.firstWhere(
                              (item) {
                                return item.id == state.assignee;
                              },
                              orElse: () => relatedItems.first,
                            ),
                            onChanged: !!isEdit
                                ? (value) {
                                    if (value != null) {
                                      cnxt
                                          .read<CreateTaskBloc>()
                                          .add(DependsLelatedtoEvent(value));
                                    }
                                  }
                                : null,
                            itemLabel: (item) => item.name,
                            enabled: !!isEdit,
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
                      onChanged: !!isEdit
                          ? (value) {
                              if (value == null) return;
                              cnxt.read<CreateTaskBloc>().add(
                                    AssigneesDropDownEvent(
                                      id: value.id,
                                      name: value.name,
                                    ),
                                  );
                            }
                          : null, // Disable if restricted
                      itemLabel: (item) => item.name,
                      enabled: !!isEdit, // Disable if restricted
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
                      onChanged: !!isEdit
                          ? (value) {
                              if (value == null) return;
                              cnxt.read<CreateTaskBloc>().add(
                                    FollowerChange(value.name, value.id),
                                  );
                            }
                          : null,
                      itemLabel: (item) => item.name,
                      enabled: !!isEdit,
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
                      value: state.priority,
                      validator: (value) {
                        return null;
                      },
                      onChanged: !!isEdit
                          ? (value) {
                              if (value != null) {
                                cnxt
                                    .read<CreateTaskBloc>()
                                    .add(PriorityChange(value));
                              }
                            }
                          : null,
                      itemLabel: (item) => item,
                      enabled: !!isEdit,
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: '0:00',
                      controller: estimateHoursController,
                      keyboardType: TextInputType.number,
                      labelText: 'Estimate hours',
                      showLabel: true,
                      enabled: !!isEdit, // Disable if restricted
                    ),
                    const SizedBox(height: 15),

                    AppTextField(
                      hint: 'Add Description',
                      controller: descriptionController,
                      maxLines: 4,
                      labelText: 'Task Description',
                      showLabel: true,
                      enabled: !!isEdit,
                    ),
                    const SizedBox(height: 20),
                    if (!isEdit)
                      SizedBox.shrink()
                    else
                      Button(
                        text: 'Update Task',
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final task = state.getTaskModel!.task;
                          final user = AuthLocalStorage.getUser();
                          final time = DateTime.now();

                          final payload = TaskUpdateRequest(
                            taskId: task.taskId,
                            adminId: task.adminId,
                            subject: subjectController.text.trim(),
                            startDate: formatDate(state.startDate),
                            endDate: formatDate(state.dueDate),
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

                          cnxt.read<CreateTaskBloc>().add(
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
