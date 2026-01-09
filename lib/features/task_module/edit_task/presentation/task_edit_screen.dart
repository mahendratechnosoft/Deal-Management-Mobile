import 'dart:developer';
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskId = GoRouterState.of(context).extra as String;
      context.read<CreateTaskBloc>().add(GetTaskEvent(taskId: taskId));
    });
    super.initState();
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
            if (state.success) {
              AppSnackBar.show(
                  type: SnackBarType.success,
                  context,
                  message: 'Task created successfully');
              context.pop();
            } else if (state.errorMessage != null) {
              AppSnackBar.show(
                  type: SnackBarType.error,
                  context,
                  message: 'Something went wrong');
            }
            if (state.getTaskModel != null) {
              final task = state.getTaskModel!.task;
              subjectController.text = task.subject;
              hourlyRateController.text = task.hourlyRate.toString();
              estimateHoursController.text = task.estimatedHours.toString();
              descriptionController.text = task.description;
              context
                  .read<CreateTaskBloc>()
                  .add(TaskStartDateChanged(task.startDate));
              context
                  .read<CreateTaskBloc>()
                  .add(TaskDueDateChanged(task.endDate));
            }
          },
          child: BlocBuilder<CreateTaskBloc, CreateTaskState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

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
                      validator: (vl) {
                        return Validators.required(vl, 'Subject');
                      },
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
                              log('Due Date: $date');
                              context
                                  .read<CreateTaskBloc>()
                                  .add(TaskDueDateChanged(date));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    /// RELATED TO DROPDOWN
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

                    /// ASSIGNEES DROPDOWN (Placeholder - expand as needed)
                    CustomDropdown<String>(
                      showLabel: true,
                      labelText: 'Assignees',
                      items: const [
                        'Non selected',
                        "A"
                        // Add real assignees here, e.g., from API
                      ],
                      value: state.assignee,
                      validator: (value) {
                        // if (value == null || value == 'Non selected') {
                        //   return 'Assignee is required';
                        // }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(AssigneeChange(value));
                        }
                      },
                      itemLabel: (item) => item,
                    ),
                    const SizedBox(height: 15),

                    /// FOLLOWERS DROPDOWN (Placeholder - expand as needed)
                    CustomDropdown<String>(
                      showLabel: true,
                      labelText: 'Followers',
                      items: const [
                        'Non selected',
                        'A'
                        // Add real followers here, e.g., from API
                      ],
                      value: state.follower,
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(FollowerChange(value));
                        }
                      },
                      itemLabel: (item) => item,
                    ),
                    const SizedBox(height: 15),

                    /// PRIORITY DROPDOWN
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
                        // if (value == null || value == 'Non selected') {
                        //   return 'Priority is required';
                        // }
                        return null;
                      },
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
                      isRequired: false,
                      minLength: 0,
                      maxLength: 200,
                    ),

                    const SizedBox(height: 15),
                    // AttachmentPicker(
                    //   maxFiles: 4,
                    //   maxFileSizeMB: 5,
                    //   allowedExtensions: [
                    //     'pdf',
                    //     'doc',
                    //     'docx',
                    //     'txt',
                    //     'jpg',
                    //     'jpeg',
                    //     'png'
                    //   ],
                    //   onFilesChanged: (files) {
                    //     context
                    //         .read<CreateTaskBloc>()
                    //         .add(AttachmentsChanged(files));
                    //   },
                    // ),
                    // const SizedBox(height: 15),
                    Button(
                      isLoading: state.isLoading,
                      text: 'Update Task',
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;

                              if (state.startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Start date is required')),
                                );
                                return;
                              }
                              if (state.dueDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Due date is required')),
                                );
                                return;
                              }

                              //final user = AuthLocalStorage.getUser();
                              final data = state.getTaskModel!.task;

                              final payload = TaskUpdateRequest(
                                taskId: data.taskId,
                                adminId: data.adminId,
                                subject: subjectController.text.trim(),
                                startDate: formatDate(state.startDate),
                                endDate: formatDate(state.dueDate),
                                priority: state.priority,
                                relatedTo: state.relatedTo,
                                relatedToId: data.relatedToId,
                                relatedToName: data.relatedToName,
                                hourlyRate: double.tryParse(
                                        hourlyRateController.text) ??
                                    0.0,
                                estimatedHours: double.tryParse(
                                        estimateHoursController.text) ??
                                    0.0,
                                description: descriptionController.text.trim(),
                                status: state.getTaskModel!.task.status,
                                assignedEmployees: [],
                                followersEmployees: [],
                                createdAt: state.getTaskModel!.task.createdAt,
                                createdBy: state.getTaskModel!.task.createdBy,
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

String formatDate(DateTime? date) {
  if (date == null) return '';
  return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";
}
