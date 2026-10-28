import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';

class CheckInOutWidget extends StatefulWidget {
  final VoidCallback? onStatusChanged;
  const CheckInOutWidget({super.key, this.onStatusChanged});

  @override
  State<CheckInOutWidget> createState() => _CheckInOutWidgetState();
}

class _CheckInOutWidgetState extends State<CheckInOutWidget> {
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final user = AuthLocalStorage.getUser();
  final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool running = false;
  int startTs = 0;
  int end = 0;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<CheckInBloc>().state;
    if (currentState is! CheckInLoaded) {
      context.read<CheckInBloc>().add(
            CheckInUserEvent(
              fromDate: currentDate,
              toDate: currentDate,
              employeeId: user?.employeeId ?? '',
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckInBloc, CheckInUserState>(
      listener: (context, state) {
        if (state is CheckInError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        if (state is CheckInLoaded) {
          widget.onStatusChanged?.call();
        }
      },
      builder: (context, state) {
        if (state is CheckInLoaded) {
          running = state.isCheckedIn;
          startTs = state.startTimestamp;
          if (state.checkInStatus.dates.isNotEmpty &&
              state.checkInStatus.dates.first.records.isNotEmpty) {
            final records = state.checkInStatus.dates.first.records;
            if (startTs == 0 && records.any((r) => r.status)) {
              startTs = records.lastWhere((r) => r.status).timeStamp;
            }
            if (!running && records.any((r) => !r.status)) {
              end = records.lastWhere((r) => !r.status).timeStamp;
            }
          }
        }

        final bool isLoading = state is CheckInLoading;

        return StreamBuilder<int>(
          stream: running ? _timerStream() : null,
          builder: (_, snap) {
            Duration elapsed = Duration.zero;

            if (running && snap.hasData && startTs > 0) {
              final diff = snap.data! - startTs;
              if (diff > 0) {
                elapsed = Duration(milliseconds: diff);
              }
            } else if (running && startTs > 0) {
              final diff = DateTime.now().millisecondsSinceEpoch - startTs;
              if (diff > 0) {
                elapsed = Duration(milliseconds: diff);
              }
            }

            return _CheckInCard(
              endTime: end,
              elapsed: elapsed,
              isCheckedIn: running,
              startTimestamp: startTs,
              isLoading: isLoading,
              onTap: () {
                if (isLoading) return;
                context.read<CheckInBloc>().add(ToggleCheckIn());
                context.read<TimeSheetBloc>().add(CheckStatusEvent(!running));
              },
            );
          },
        );
      },
    );
  }
}

Stream<int> _timerStream() async* {
  yield DateTime.now().millisecondsSinceEpoch;
  yield* Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().millisecondsSinceEpoch,
  );
}

class _CheckInCard extends StatelessWidget {
  final Duration elapsed;
  final bool isCheckedIn;
  final VoidCallback onTap;
  final int startTimestamp;
  final int endTime;
  final bool isLoading;

  const _CheckInCard({
    required this.elapsed,
    required this.isCheckedIn,
    required this.onTap,
    required this.startTimestamp,
    required this.endTime,
    this.isLoading = false,
  });

  String _format(Duration d) {
    String t(int n) => n.toString().padLeft(2, '0');
    return "${t(d.inHours)}:"
        "${t(d.inMinutes.remainder(60))}:"
        "${t(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue.shade700;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCheckedIn ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    size: 18,
                    color: isCheckedIn ? Colors.green : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Work Session Today",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              _StatusChip(isCheckedIn),
            ],
          ),

          const SizedBox(height: 12),

          /// TIMER DISPLAY
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _format(elapsed),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isCheckedIn ? const Color(0xFF0F172A) : Colors.grey.shade600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              if (isCheckedIn)
                Text(
                  "active",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          /// META INFO (Check In / Check Out times)
          if (startTimestamp > 0 || endTime > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (startTimestamp > 0)
                    _MetaItem(
                      label: "Check In",
                      value: formatStartTime(startTimestamp),
                    ),
                  const Spacer(),
                  if (endTime > startTimestamp)
                    _MetaItem(
                      label: "Last Out",
                      value: formatStartTime(endTime),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          /// ACTION BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onTap,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
              label: Text(
                isLoading
                    ? 'Updating...'
                    : (isCheckedIn ? 'Check Out' : 'Check In'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.red.shade600 : primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool checkedIn;
  const _StatusChip(this.checkedIn);

  @override
  Widget build(BuildContext context) {
    final color = checkedIn ? Colors.green.shade700 : Colors.grey.shade600;
    final bg = checkedIn ? Colors.green.shade50 : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: checkedIn ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            checkedIn ? 'Checked In' : 'Checked Out',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

String formatStartTime(int ts) {
  if (ts <= 0) return "--:--";
  final dt = DateTime.fromMillisecondsSinceEpoch(ts);
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return "$hour:$minute $period";
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
