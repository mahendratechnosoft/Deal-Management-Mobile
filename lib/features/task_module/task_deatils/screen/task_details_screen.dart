import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/info_dailog_widgte.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/statistics_widget.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/task_info_widget.dart';
import '../../create_task/model/assign_model.dart';
import '../widget/comment_widget.dart';
import '../widget/common_widget.dart';
import '../widget/start_time_widget.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({super.key});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskId = GoRouterState.of(context).extra as String;
      context.read<CreateTaskBloc>().add(GetTaskEvent(taskId: taskId));
      context.read<CreateTaskBloc>().add(LoadAssigneesEvent());
      context.read<CreateTaskBloc>().add(
            TimerStatusEvent(taskId: taskId),
          );
    });
  }

  List<DropdownItem> getAssigneeDropdownItems(
    List<AssignModel> allItems,
    List<DropdownItem> selectedAssignees,
    List<DropdownItem> selectedFollowers,
  ) {
    final availableItems = allItems.where((assignee) {
      return !selectedFollowers
          .any((follower) => follower.id == assignee.employeeId);
    });

    return availableItems.map((assignee) {
      final isSelected = selectedAssignees
          .any((selected) => selected.id == assignee.employeeId);

      return DropdownItem(
        id: assignee.employeeId,
        name: isSelected ? '${assignee.name} ✓' : assignee.name,
        displayName: isSelected ? '${assignee.name} ✓' : assignee.name,
        isSelected: isSelected,
      );
    }).toList();
  }

  List<DropdownItem> getFollowerDropdownItems(
    List<AssignModel> allItems,
    List<DropdownItem> selectedFollowers,
    List<DropdownItem> selectedAssignees,
  ) {
    final availableItems = allItems.where((assignee) {
      return !selectedAssignees
          .any((assigneeItem) => assigneeItem.id == assignee.employeeId);
    });

    return availableItems.map((assignee) {
      final isSelected = selectedFollowers
          .any((selected) => selected.id == assignee.employeeId);

      return DropdownItem(
        id: assignee.employeeId,
        name: isSelected ? '${assignee.name} ✓' : assignee.name,
        displayName: isSelected ? '${assignee.name} ✓' : assignee.name,
        isSelected: isSelected,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Task Details'),
      body: BlocBuilder<CreateTaskBloc, CreateTaskState>(
        builder: (context, state) {
          if (state.isLoading || state.getTaskModel == null) {
            return SkeletonCard(
              isLoading: true,
              itemCount: 10,
              borderRadius: 16,
              padding: EdgeInsets.symmetric(vertical: 20),
            );
          }

          final task = state.getTaskModel!.task;
          final timerStatus = state.checktimerStatus;

          if (timerStatus == null) {
            log('⏳ Timer status is null');
          } else {
            log('status check ${timerStatus.status}');
          }
          final assigneeDropdownItems = getAssigneeDropdownItems(
            state.assigneesList,
            state.selectedAssignees,
            state.selectedFollower,
          );

          final followerDropdownItems = getFollowerDropdownItems(
            state.assigneesList,
            state.selectedFollower,
            state.selectedAssignees,
          );

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(16),
              vertical: Responsive.h(12),
            ),
            child: ListView(
              children: [
                /// STATUS ROW
                Row(
                  children: [
                    Expanded(
                      //  flex: 2,
                      child: CommonDropdown<String>(
                        hintText: 'Status',
                        value: 'Time Logs',
                        items: const [
                          'Time Logs',
                          'Statistics',
                          'Comments',
                          'Attchments',
                        ],
                        onChanged: (value) {
                          final taskId =
                              GoRouterState.of(context).extra as String;
                          log('Status: $value');
                          if (value == 'Time Logs') {
                            showTimeLogsDialog(context, taskId);
                          } else if (value == 'Statistics') {
                            showWeeklyTimeDialog(context, state);
                          } else if (value == 'Comments') {
                            showCommentDialog(
                              context: context,
                              taskId: taskId,
                            );
                          } else {
                            showAttachmentsDialog(context, taskId);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CommonDropdown<String>(
                        hintText: 'Status',
                        value: resolveStatusLabel(task.status),
                        items: taskStatusMap.values.toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final taskId =
                              GoRouterState.of(context).extra as String;
                          final apiValue = taskStatusMap.entries
                              .firstWhere((e) => e.value == value)
                              .key;

                          context
                              .read<CreateTaskBloc>()
                              .add(UpdatedStatusEvent(taskId, apiValue));
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          Text(
                            task.subject,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              if (state.isTimerRunning) {
                                showStopTimerDialog(
                                  context: context,
                                  elapsedSeconds: state.elapsedSeconds,
                                  onSubmit: (note) {
                                    context.read<CreateTaskBloc>().add(
                                          StopTaskTimerEvent(task.taskId, note),
                                        );
                                  },
                                );
                              } else {
                                log('🟢 START timer');
                                //bloc.add(StartTaskTimerEvent(task.taskId));
                                showStartSuccessDialog(
                                  context: context,
                                  onConfirm: () {
                                    context.read<CreateTaskBloc>().add(
                                          StartTaskTimerEvent(task.taskId),
                                        );
                                  },
                                );
                              }
                            },
                            child: Chip(
                              backgroundColor: state.isTimerRunning
                                  ? Colors.red
                                  : AppColors.primary,
                              label: Text(
                                state.isTimerRunning ? 'Stop' : 'Start',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// TOTAL TIME
                      infoRow(
                        title: 'Time Tracking',
                        value: formatDuration(state.elapsedSeconds),
                      ),

                      const SizedBox(height: 8),

                      /// SESSION STATUS
                      Row(
                        children: [
                          const Text(
                            'Current session',
                            style: TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.radio_button_checked,
                            size: 12,
                            color: state.isTimerRunning
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.isTimerRunning ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: state.isTimerRunning
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// INFO CARD
                TaskInformationCard(task: task),

                const SizedBox(height: 16),

                /// ASSIGNEE
                TaskActionCard(
                  name: '1',
                  title: 'Assignee',
                  label: 'Add Assignee',
                  emptyText: 'No assignee selected',
                  items: assigneeDropdownItems,
                  selectedId: state.selectedAssignees.isNotEmpty
                      ? state.selectedAssignees.first.id
                      : '',
                  edit: state.canEdit,
                  onChanged: (item) {
                    if (state.selectedAssignees.any((e) => e.id == item.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${item.name} is already selected as assignee'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    context.read<CreateTaskBloc>().add(
                          AddAssigneeLocal(item),
                        );

                    context.read<CreateTaskBloc>().add(
                          AddAssigneeEvent(
                            taskId: task.taskId,
                            employeeIds: [item.id],
                          ),
                        );
                  },
                ),

                // Show selected assignees from state
                state.selectedAssignees.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 55,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.selectedAssignees.length,
                          itemBuilder: (_, index) {
                            final item = state.selectedAssignees[index];
                            return assigneeRow(
                              item: item,
                              onRemove: () {
                                context.read<CreateTaskBloc>().add(
                                      RemoveAssigneeLocal(item.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 16),

                /// FOLLOWER
                TaskActionCard(
                  edit: state.canEdit,
                  name: '2',
                  title: 'Follower',
                  label: 'Add Follower',
                  emptyText: 'No follower selected',
                  items: followerDropdownItems,
                  selectedId: state.selectedFollower.isNotEmpty
                      ? state.selectedFollower.first.id
                      : '',
                  onChanged: (item) {
                    if (state.selectedFollower.any((e) => e.id == item.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${item.name} is already selected as follower'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    context.read<CreateTaskBloc>().add(
                          AddFollowerLocal(item),
                        );

                    context.read<CreateTaskBloc>().add(AddFollowerEvent(
                          taskId: task.taskId,
                          employeeIds: [item.id],
                        ));
                  },
                ),

                // Show selected followers from state
                state.selectedFollower.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 55,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.selectedFollower.length,
                          itemBuilder: (_, index) {
                            final item = state.selectedFollower[index];
                            return assigneeRow(
                              item: item,
                              onRemove: () {
                                context.read<CreateTaskBloc>().add(
                                      RemoveFollowerLocal(item.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoRow({required String title, required String value}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

const Map<String, String> taskStatusMap = {
  'NOT_STARTED': 'Not started',
  'IN_PROGRESS': 'In progress',
  'TESTING': 'Testing',
  'AWAITING_FEEDBACK': 'Awaiting Feedback',
  'COMPLETE': 'Complete',
};

String resolveStatusLabel(String? apiStatus) {
  if (apiStatus == null) return 'Not started';
  return taskStatusMap[apiStatus] ?? 'Not started';
}

String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;

  return '${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}:'
      '${s.toString().padLeft(2, '0')}';
}

Widget assigneeRow({
  required DropdownItem item,
  required VoidCallback onRemove,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        /// Avatar (Initials)
        Chip(
          backgroundColor: AppColors.primaryDark,
          label: Text(
            _getInitials(item.name),
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.sp(8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 5),

        /// Name

        /// Remove Button
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onRemove,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.red.shade400,
            ),
          ),
        ),
      ],
    ),
  );
}

String _getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length == 1) {
    return name;
  }
  return name;
}
