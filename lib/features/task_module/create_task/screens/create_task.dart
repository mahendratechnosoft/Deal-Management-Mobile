import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/utils/validators.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_button.dart';
import 'package:xpertbiz/core/widgtes/app_snackbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/attchment_widget.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_model.dart';
import '../bloc/create_task_bloc.dart';

class CreateTask extends StatelessWidget {
  CreateTask({super.key});
  final subjectController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final estimateHoursController = TextEditingController();
  final descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Create Task'),
      body: SafeArea(
        minimum: const EdgeInsets.all(10),
        child: BlocListener<CreateTaskBloc, CreateTaskState>(
          listener: (context, state) {
            if (state.taskCreated) {
              AppSnackBar.show(
                type: SnackBarType.success,
                context,
                message: 'Task created successfully',
              );
              context.pop();
            }

            if (state.errorMessage != null) {
              AppSnackBar.show(
                type: SnackBarType.error,
                context,
                message: state.errorMessage!,
              );
            }
          },
          child: BlocBuilder<CreateTaskBloc, CreateTaskState>(
            builder: (context, state) {
              final assigneeItems = [
                DropdownItem(id: '', name: 'Non selected'),
                ...getAssigneeItems(state),
              ];
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
                          context.read<CreateTaskBloc>().add(RelatedChange(
                                value,
                              ));
                          context
                              .read<CreateTaskBloc>()
                              .add(FetchAssignEvent(value: value));
                        }
                      },
                      itemLabel: (item) => item,
                    ),
                    const SizedBox(height: 15),

                    CustomDropdown<DropdownItem>(
                      showLabel: true,
                      labelText: state.relatedTo == 'Non selected'
                          ? 'Assignees'
                          : 'Select ${state.relatedTo}',
                      items: assigneeItems,
                      value: assigneeItems.firstWhere(
                        (item) {
                          return item.id == state.assignee;
                        },
                        orElse: () => assigneeItems[0],
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(AssigneeChange(value.id));
                        }
                      },
                      itemLabel: (item) => item.name,
                    ),

                    const SizedBox(height: 15),
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
                    AttachmentPicker(
                      maxFiles: 4,
                      maxFileSizeMB: 5,
                      allowedExtensions: [
                        'pdf',
                        'doc',
                        'docx',
                        'txt',
                        'jpg',
                        'jpeg',
                        'png'
                      ],
                      onFilesChanged: (files) {
                        context
                            .read<CreateTaskBloc>()
                            .add(AttachmentsChanged(files));
                      },
                    ),
                    const SizedBox(height: 15),
                    Button(
                      isLoading: state.isLoading,
                      text: 'Create Task',
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

                              final user = AuthLocalStorage.getUser();

                              final request = CreateTaskRequest(
                                task: Task(
                                  subject: subjectController.text.trim(),
                                  startDate: formatDate(state.startDate),
                                  endDate: formatDate(state.dueDate),
                                  priority: state.priority,
                                  relatedTo: state.relatedTo,
                                  relatedToId: state.assignee,
                                  relatedToName: '',
                                  hourlyRate: double.tryParse(
                                          hourlyRateController.text.trim()) ??
                                      0,
                                  estimatedHours: double.tryParse(
                                          estimateHoursController.text
                                              .trim()) ??
                                      0,
                                  description:
                                      descriptionController.text.trim(),
                                  assignedEmployees: [
                                    Employee(
                                      employeeId: user?.userId ?? '',
                                      name: user?.loginUserName ?? 'User',
                                    )
                                  ],
                                  followersEmployees: [],
                                ),

                                /// Attachments converted correctly
                                taskAttachments: state.attachments
                                    .map(
                                      (file) => TaskAttachment(
                                        fileName: file.name,
                                        contentType: file.extension ??
                                            'application/octet-stream',
                                        data:
                                            '', // backend accepts empty string
                                      ),
                                    )
                                    .toList(),
                              );

                              context.read<CreateTaskBloc>().add(
                                    SubmitCreateTask(request: request),
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

List<DropdownItem> getAssigneeItems(CreateTaskState state) {
  switch (state.relatedTo) {
    case 'Lead':
      return state.leadList
          .where((e) => e.clientName.trim().isNotEmpty)
          .map((e) => DropdownItem(id: e.leadId, name: e.clientName))
          .toList();

    case 'Customer':
      return state.customerList
          .where((e) => e.companyName.trim().isNotEmpty)
          .map((e) => DropdownItem(id: e.id, name: e.companyName))
          .toList();

    case 'Proforma':
      return state.proformList
          .where((e) => e.formatedProformaInvoiceNumber.trim().isNotEmpty)
          .map((e) => DropdownItem(
              id: e.proformaInvoiceId, name: e.formatedProformaInvoiceNumber))
          .toList();

    case 'Proposal':
      return state.proposalList
          .where((e) => e.formatedProposalNumber.trim().isNotEmpty)
          .map((e) =>
              DropdownItem(id: e.proposalId, name: e.formatedProposalNumber))
          .toList();

    case 'Invoice':
      return state.invoiceList
          .where((e) => e.formatedInvoiceNumber.trim().isNotEmpty)
          .map((e) =>
              DropdownItem(id: e.invoiceId, name: e.formatedInvoiceNumber))
          .toList();

    default:
      return [];
  }
}
