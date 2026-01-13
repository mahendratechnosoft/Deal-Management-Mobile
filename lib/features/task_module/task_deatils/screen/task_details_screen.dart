import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/common_widget.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/info_dailog_widgte.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/statistics_widget.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/task_info_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Task Details'),
      body: BlocBuilder<CreateTaskBloc, CreateTaskState>(
        builder: (context, state) {
          if (state.isLoading || state.getTaskModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final task = state.getTaskModel!.task;
          final timerStatus = state.checktimerStatus;

          if (timerStatus == null) {
            log('⏳ Timer status is null');
          } else {
            log('status check ${timerStatus.status}');
          }
          final assigneeList = state.assigneesList
              .where((e) => e.employeeId != state.followerId)
              .map(
                (e) => DropdownItem(
                  id: e.employeeId,
                  name: e.name,
                ),
              )
              .toList();

          final followerList = state.assigneesList
              .where((e) => e.employeeId != state.assignIdValue)
              .map(
                (e) => DropdownItem(
                  id: e.employeeId,
                  name: e.name,
                ),
              )
              .toList();
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
                            context
                                .read<CreateTaskBloc>()
                                .add(TimerDetailsEvent(taskId: taskId));

                            showTimeLogsDialog(context, state);
                          } else if (value == 'Statistics') {
                            showWeeklyTimeDialog(context, state);
                          } else if (value == 'Comments') {
                            showCommentDialog(
                              context: context,
                              onSubmit: (comment) {
                                // Handle submitted comment
                                print('Comment submitted: $comment');
                              },
                            );
                          } else {
                            showAttachmentsDialog(
                              context: context,
                              onFilesSelected: (files) {
                                // Handle selected files
                                print('Files selected: $files');
                              },
                            );
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

                          final apiValue = taskStatusMap.entries
                              .firstWhere((e) => e.value == value)
                              .key;

                          log('Selected API status: $apiValue');
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
                              final bloc = context.read<CreateTaskBloc>();

                              if (state.isTimerRunning) {
                                // 🟥 Timer चालू आहे → STOP
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
                                // 🟢 Timer बंद आहे / null आहे → START
                                log('🟢 START timer');
                                bloc.add(StartTaskTimerEvent(task.taskId));
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
                  items: assigneeList,
                  selectedId: state.assignIdValue,
                  onChanged: (item) {
                    context.read<CreateTaskBloc>().add(
                          AssigneesDropDownEvent(
                            id: item.id,
                            name: item.name,
                          ),
                        );
                  },
                ),

                const SizedBox(height: 16),

                /// FOLLOWER
                TaskActionCard(
                  name: '2',
                  title: 'Follower',
                  label: 'Add Follower',
                  emptyText: 'No follower selected',
                  items: followerList,
                  selectedId: state.followerId,
                  onChanged: (item) {
                    context.read<CreateTaskBloc>().add(
                          FollowerChange(
                            item.name,
                            item.id,
                          ),
                        );
                  },
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
