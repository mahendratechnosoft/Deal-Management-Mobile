import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/activity_log_model.dart';

class ActivityLogView extends StatelessWidget {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, state) {
        if (state is! AllLeadState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.activityLogsLoader) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.activityLogs.isEmpty) {
          return _emptyView();
        }

        final groupedLogs = _groupByDate(state.activityLogs);

        return RefreshIndicator(
          onRefresh: () async {
            if (state.leadDetailsModel != null) {
              context.read<LeadBloc>().add(
                    FetchLeadActivityEvent(
                      state.leadDetailsModel!.lead.id,
                    ),
                  );
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: groupedLogs.entries.map((entry) {
              return _dateSection(entry.key, entry.value);
            }).toList(),
          ),
        );
      },
    );
  }

  /// ================= DATE SECTION =================

  Widget _dateSection(String date, List<ActivityLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dateChip(date),
        const SizedBox(height: 12),
        Stack(
          children: [
            /// Vertical line
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.blue.shade200,
              ),
            ),

            Column(
              children: logs.map(_timelineItem).toList(),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// ================= DATE CHIP =================

  Widget _dateChip(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ================= TIMELINE ITEM =================

  Widget _timelineItem(ActivityLogModel log) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Dot
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),

          /// Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _meta(
                        Icons.access_time,
                        DateFormat('hh:mm a').format(log.createdDateTime),
                      ),
                      const SizedBox(width: 12),
                      _meta(
                        Icons.person_outline,
                        'By ${log.createdBy}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= HELPERS =================

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Text(
        'No activity found',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Map<String, List<ActivityLogModel>> _groupByDate(
    List<ActivityLogModel> logs,
  ) {
    final Map<String, List<ActivityLogModel>> map = {};

    for (final log in logs) {
      final date = DateFormat('MMM d, yyyy').format(log.createdDateTime);
      map.putIfAbsent(date, () => []);
      map[date]!.add(log);
    }
    return map;
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
