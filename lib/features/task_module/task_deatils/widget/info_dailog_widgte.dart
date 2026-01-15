import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'package:xpertbiz/features/task_module/create_task/model/time_detail_model.dart';

import '../../create_task/bloc/create_task_event.dart';

void showTimeLogsDialog(BuildContext context, String taskId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return BlocProvider.value(
        value: BlocProvider.of<CreateTaskBloc>(context)
          ..add(TimerDetailsEvent(taskId: taskId)),
        child: const TimeLogsDialog(),
      );
    },
  );
}

class TimeLogsDialog extends StatelessWidget {
  const TimeLogsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      elevation: 8,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: BlocListener<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {},
        child: BlocBuilder<CreateTaskBloc, CreateTaskState>(
          buildWhen: (previous, current) =>
              previous.timeDetailsModel != current.timeDetailsModel ||
              previous.isLoading != current.isLoading,
          builder: (context, state) {
            return _buildDialogContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, CreateTaskState state) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 520,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogHeader(context: context),
          if (state.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.timeDetailsModel.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No time logs available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else ...[
            _SummarySection(logs: state.timeDetailsModel),
            const Divider(height: 1),

            // Time logs list
            Expanded(
              child: _TimeLogsList(logs: state.timeDetailsModel),
            ),
          ],
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final BuildContext context;

  const _DialogHeader({required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Text(
            'Time Logs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final List<TimeDetailsModel> logs;

  const _SummarySection({required this.logs});

  @override
  Widget build(BuildContext context) {
    final totalMinutes =
        logs.fold<int>(0, (sum, e) => sum + e.durationInMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final totalTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Total Time',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              totalTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeLogsList extends StatelessWidget {
  final List<TimeDetailsModel> logs;

  const _TimeLogsList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = logs[index];
        return _TimeLogTile(item: item);
      },
    );
  }
}

class _TimeLogTile extends StatelessWidget {
  final TimeDetailsModel item;

  const _TimeLogTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(item.name);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Duration
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        '${item.durationInMinutes} min',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),

                _LogInfoRow(label: 'Note', value: item.endNote),
                _LogInfoRow(
                  label: 'Start',
                  value: _formatDateTime(item.startTime),
                ),
                _LogInfoRow(
                  label: 'End',
                  value: item.endTime == null
                      ? 'In Progress'
                      : _formatDateTime(item.endTime!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'NA';

    return name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return '${dt.day.toString().padLeft(2, '0')} '
        '${months[dt.month - 1]} ${dt.year} · '
        '$hour:$minute $amPm';
  }
}

class _LogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _LogInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
