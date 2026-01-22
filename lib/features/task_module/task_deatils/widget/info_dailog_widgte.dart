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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade600,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
                /// NAME + DURATION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name.trim().split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DurationBadge(
                      text: formatDuration(item.durationInMinutes),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                if (item.endNote.isNotEmpty)
                  Text(
                    item.endNote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),

                const SizedBox(height: 8),

                _MetaRow(
                  icon: Icons.play_arrow_rounded,
                  text: _formatDateTime(item.startTime),
                ),

                _MetaRow(
                  icon: Icons.stop_rounded,
                  text: item.endTime == null
                      ? 'In Progress'
                      : _formatDateTime(item.endTime!),
                  highlight: item.endTime == null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  String formatDuration(int minutes) {
    if (minutes <= 0) return '0 min';

    final totalHours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (totalHours == 0) {
      return '$minutes min';
    }

    if (totalHours < 12) {
      return remainingMinutes == 0
          ? '$totalHours hr'
          : '$totalHours hr $remainingMinutes min';
    }

    final days = totalHours ~/ 24;
    final remainingHours = totalHours % 24;

    if (days == 0) {
      return '$totalHours hr';
    }

    return remainingHours == 0
        ? '$days day${days > 1 ? 's' : ''}'
        : '$days day${days > 1 ? 's' : ''} $remainingHours hr';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'NA';

    return name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0])
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

class _DurationBadge extends StatelessWidget {
  final String text;

  const _DurationBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;

  const _MetaRow({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: highlight ? Colors.orange : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
