import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/timesheet/block/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/block/timesheet_event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';

class CheckInOutWidget extends StatefulWidget {
  const CheckInOutWidget({super.key});

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
    context.read<CheckInBloc>().add(
          CheckInUserEvent(
            fromDate: currentDate,
            toDate: currentDate,
            employeeId: user?.employeeId ?? '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckInBloc, CheckInUserState>(
      listener: (context, state) {
        if (state is CheckInError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        // if (state is TimeSheetLoaded) {
        //   // running = state.isCheckedIn;

        //   if (state.checkInStatus != null &&
        //       state.checkInStatus!.dates.isNotEmpty &&
        //       state.checkInStatus!.dates.first.records.isNotEmpty) {
        //     final lastRecord = state.checkInStatus!.dates.first.records;
        //     startTs = lastRecord.first.timeStamp;
        //     end = lastRecord.last.timeStamp;
        //   } else {
        //     startTs = state.startTimestamp ?? 0;
        //   }
        // }
        if (state is CheckInLoaded) {
          running = state.isCheckedIn;
          final lastRecord = state.checkInStatus.dates.first.records;
          startTs = lastRecord.first.timeStamp;
          end = lastRecord.last.timeStamp;
        }

        return StreamBuilder<int>(
          stream: running ? _timerStream() : null,
          builder: (_, snap) {
            Duration elapsed = Duration.zero;

            if (running && snap.hasData && startTs > 0) {
              final diff = snap.data! - startTs;

              // safety guard
              if (diff > 0) {
                elapsed = Duration(milliseconds: diff);
              }
            }
            return _CheckInCard(
              endTime: end,
              elapsed: elapsed,
              isCheckedIn: running,
              startTimestamp: startTs,
              onTap: () {
                context.read<TimeSheetBloc>().add(CheckStatusEvent(!running));
                context.read<TimeSheetBloc>().add(ResetToEmployeeList(today));
              },
            );
          },
        );
      },
    );
  }
}

Stream<int> _timerStream() async* {
  // 🔥 emit immediately
  yield DateTime.now().millisecondsSinceEpoch;

  // ⏱ then every second
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

  const _CheckInCard({
    required this.elapsed,
    required this.isCheckedIn,
    required this.onTap,
    required this.startTimestamp,
    required this.endTime,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(.08),
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
              const Text(
                "Work Session",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _StatusChip(isCheckedIn),
            ],
          ),

          const SizedBox(height: 10),

          /// TIMER
          Text(
            _format(elapsed),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          /// META INFO
          if (startTimestamp > 0)
            Row(
              children: [
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

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          /// ACTION BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(
                isCheckedIn ? Icons.logout : Icons.login,
                color: AppColors.background,
                size: 18,
              ),
              label: Text(
                isCheckedIn ? 'Check Out' : 'Check In',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.red.shade500 : primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
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
    final color = checkedIn ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            checkedIn ? Icons.play_circle_fill : Icons.pause_circle_filled,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            checkedIn ? 'Checked In' : 'Not Started',
            style: TextStyle(
              fontSize: 12,
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
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
