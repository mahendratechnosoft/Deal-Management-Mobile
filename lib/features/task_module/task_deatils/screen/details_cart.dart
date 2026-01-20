import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_drop_down.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/info_dailog_widgte.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/statistics_widget.dart';
import 'package:xpertbiz/features/task_module/task_deatils/widget/task_info_widget.dart';
import '../widget/comment_widget.dart';
import '../widget/common_widget.dart';
import '../widget/start_time_widget.dart';
import 'helper_widget.dart';

Widget detailsWidget(BuildContext context, CreateTaskState state) {
  final task = state.getTaskModel!.task;

  
  final taskId = GoRouterState.of(context).extra as String;

  final assigneeItems = buildAssigneeDropdownItems(
    allItems: state.assigneesList,
    selectedAssignees: state.selectedAssignees,
    selectedFollowers: state.selectedFollower,
  );

  final followerItems = buildFollowerDropdownItems(
    allItems: state.assigneesList,
    selectedFollowers: state.selectedFollower,
    selectedAssignees: state.selectedAssignees,
  );

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: Responsive.w(16),
      vertical: Responsive.h(12),
    ),
    child: ListView(
      children: [
        _statusRow(context, state, task, taskId),
        const SizedBox(height: 16),
        _timerCard(context, state, task),
        const SizedBox(height: 16),
        TaskInformationCard(task: task),
        const SizedBox(height: 16),
        _assigneeSection(context, state, task, assigneeItems),
        const SizedBox(height: 16),
        _followerSection(context, state, task, followerItems),
      ],
    ),
  );
}

Widget _followerSection(
  BuildContext context,
  CreateTaskState state,
  task,
  List<DropdownItem> items,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TaskActionCard(
        edit: state.canEdit,
        name: '2',
        title: 'Follower',
        label: 'Add Follower',
        emptyText: 'No follower selected',
        items: items,
        selectedId: state.selectedFollower.isNotEmpty
            ? state.selectedFollower.first.id
            : '',
        onChanged: (item) {
          if (state.selectedFollower.any((e) => e.id == item.id)) {
            _showSnack(
              context,
              '${item.name} is already selected as follower',
            );
            return;
          }

          context.read<CreateTaskBloc>().add(
                AddFollowerLocal(item),
              );

          context.read<CreateTaskBloc>().add(
                AddFollowerEvent(
                  taskId: task.taskId,
                  employeeIds: [item.id],
                ),
              );
        },
      ),

      /// Selected followers chips
      if (state.selectedFollower.isNotEmpty)
        SizedBox(
          height: 55,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.selectedFollower.length,
            itemBuilder: (_, index) {
              final item = state.selectedFollower[index];
              return assigneeRow(
                item: item,
                onRemove: () {
                  context
                      .read<CreateTaskBloc>()
                      .add(RemoveFollowerLocal(item.id));
                },
              );
            },
          ),
        ),
    ],
  );
}

Widget _statusRow(
  BuildContext context,
  CreateTaskState state,
  task,
  String taskId,
) {
  return Row(
    children: [
      Expanded(
        child: CommonDropdown<String>(
          hintText: 'Status',
          value: 'Time Logs',
          items: const ['Time Logs', 'Statistics', 'Comments', 'Attchments'],
          onChanged: (value) {
            if (value == 'Time Logs') {
              showTimeLogsDialog(context, taskId);
            } else if (value == 'Statistics') {
              showWeeklyTimeDialog(context, state);
            } else if (value == 'Comments') {
              showCommentDialog(context: context, taskId: taskId);
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
          value: statusLable(task.status),
          items: taskStatusMap.values.toList(),
          onChanged: (value) {
            if (value == null) return;
            final apiValue =
                taskStatusMap.entries.firstWhere((e) => e.value == value).key;
            context
                .read<CreateTaskBloc>()
                .add(UpdatedStatusEvent(taskId, apiValue));
          },
        ),
      ),
    ],
  );
}

Widget _timerCard(
  BuildContext context,
  CreateTaskState state,
  task,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderDark),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(task.subject,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            _startStopButton(context, state, task),
          ],
        ),
        const SizedBox(height: 12),
        infoRow(
          title: 'Time Tracking',
          value: formater(state.elapsedSeconds),
        ),
        const SizedBox(height: 8),
        _sessionStatus(state),
      ],
    ),
  );
}

Widget _sessionStatus(CreateTaskState state) {
  return Row(
    children: [
      const Text(
        'Current session',
        style: TextStyle(fontSize: 12),
      ),
      const Spacer(),
      Icon(
        Icons.radio_button_checked,
        size: 12,
        color: state.isTimerRunning ? Colors.green : Colors.grey,
      ),
      const SizedBox(width: 6),
      Text(
        state.isTimerRunning ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: state.isTimerRunning ? Colors.green : Colors.grey,
        ),
      ),
    ],
  );
}

Widget _startStopButton(
  BuildContext context,
  CreateTaskState state,
  task,
) {
  return InkWell(
    onTap: () {
      if (state.isTimerRunning) {
        showStopTimerDialog(
          context: context,
          elapsedSeconds: state.elapsedSeconds,
          onSubmit: (note) {
            context
                .read<CreateTaskBloc>()
                .add(StopTaskTimerEvent(task.taskId, note));
          },
        );
      } else {
        showStartSuccessDialog(
          context: context,
          onConfirm: () {
            context
                .read<CreateTaskBloc>()
                .add(StartTaskTimerEvent(task.taskId));
          },
        );
      }
    },
    child: Chip(
      backgroundColor: state.isTimerRunning ? Colors.red : AppColors.primary,
      label: Text(
        state.isTimerRunning ? 'Stop' : 'Start',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    ),
  );
}

Widget _assigneeSection(
  BuildContext context,
  CreateTaskState state,
  task,
  List<DropdownItem> items,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TaskActionCard(
        name: '1',
        title: 'Assignee',
        label: 'Add Assignee',
        emptyText: 'No assignee selected',
        items: items,
        selectedId: state.selectedAssignees.isNotEmpty
            ? state.selectedAssignees.first.id
            : '',
        edit: state.canEdit,
        onChanged: (item) {
          if (state.selectedAssignees.any((e) => e.id == item.id)) {
            _showSnack(context, '${item.name} already added');
            return;
          }

          context.read<CreateTaskBloc>().add(AddAssigneeLocal(item));

          context.read<CreateTaskBloc>().add(
                AddAssigneeEvent(
                  taskId: task.taskId,
                  employeeIds: [item.id],
                ),
              );
        },
      ),

      /// ✅ Selected assignees list (MISSING PART)
      if (state.selectedAssignees.isNotEmpty)
        SizedBox(
          height: 55,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.selectedAssignees.length,
            itemBuilder: (_, index) {
              final item = state.selectedAssignees[index];
              return assigneeRow(
                item: item,
                onRemove: () {
                  context
                      .read<CreateTaskBloc>()
                      .add(RemoveAssigneeLocal(item.id));
                },
              );
            },
          ),
        ),
    ],
  );
}

void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
