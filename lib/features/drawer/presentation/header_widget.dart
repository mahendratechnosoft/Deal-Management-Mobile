import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';

class DrawerHeaderWidget extends StatefulWidget {
  const DrawerHeaderWidget({super.key});

  @override
  State<DrawerHeaderWidget> createState() => _DrawerHeaderWidgetState();
}

class _DrawerHeaderWidgetState extends State<DrawerHeaderWidget> {
  @override
  void initState() {
    super.initState();
    final checkInState = context.read<CheckInBloc>().state;
    if (checkInState is! CheckInLoaded) {
      final user = AuthLocalStorage.getUser();
      final role = RoleResolver.rolePath;
      final bool hasAccess = user?.moduleAccess.timeSheetAccess ?? false;
      if (role == 'employee' && hasAccess) {
        final String currentDate =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        context.read<CheckInBloc>().add(
              CheckInUserEvent(
                fromDate: currentDate,
                toDate: currentDate,
                employeeId: user?.employeeId ?? '',
              ),
            );
      }
    }
  }

  /// Extract initials from full name
  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return "NA";
    }

    final parts = fullName.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Stream<int> _timerStream() async* {
    yield DateTime.now().millisecondsSinceEpoch;
    yield* Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now().millisecondsSinceEpoch,
    );
  }

  String _format(Duration d) {
    String t(int n) => n.toString().padLeft(2, '0');
    return "${t(d.inHours)}:${t(d.inMinutes.remainder(60))}:${t(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<LoginResponse>(ApiConstants.boxName);

    return ValueListenableBuilder<Box<LoginResponse>>(
      valueListenable: box.listenable(),
      builder: (context, box, _) {
        final user = box.get(ApiConstants.userKey);

        final name = user?.loginUserName?.trim().isNotEmpty == true
            ? user!.loginUserName!
            : user?.loginEmail ?? "NA";

        final email = user?.loginEmail ?? "Not logged in";
        final initials = _getInitials(user?.loginUserName);
        final role = RoleResolver.rolePath;
        final bool canCheckIn =
            role == 'employee' && (user?.moduleAccess.timeSheetAccess ?? false);

        return Container(
          margin: EdgeInsets.fromLTRB(
            Responsive.h(12),
            Responsive.h(8),
            Responsive.h(12),
            Responsive.h(6),
          ),
          padding: EdgeInsets.all(Responsive.h(10)),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Slate 800
            borderRadius: BorderRadius.circular(Responsive.h(12)),
            border: Border.all(
              color: const Color(0xFF334155), // Slate 700
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: Responsive.h(40),
                    height: Responsive.h(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(Responsive.h(10)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: Responsive.h(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.h(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Responsive.h(13.5),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: Responsive.h(2)),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Responsive.h(11.5),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// INTEGRATED ATTENDANCE SHORTCUT (FOR EMPLOYEES)
              if (canCheckIn) ...[
                SizedBox(height: Responsive.h(10)),
                Container(
                  padding: EdgeInsets.only(top: Responsive.h(9)),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF334155),
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: BlocConsumer<CheckInBloc, CheckInUserState>(
                    listener: (context, state) {
                      if (state is CheckInError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final bool isLoading = state is CheckInLoading;
                      final bool isCheckedIn =
                          state is CheckInLoaded && state.isCheckedIn;

                      int startTs = 0;
                      if (state is CheckInLoaded) {
                        startTs = state.startTimestamp;
                        if (startTs == 0 &&
                            state.checkInStatus.dates.isNotEmpty &&
                            state.checkInStatus.dates.first.records.isNotEmpty) {
                          final records =
                              state.checkInStatus.dates.first.records;
                          if (records.any((r) => r.status)) {
                            startTs = records.lastWhere((r) => r.status).timeStamp;
                          }
                        }
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: StreamBuilder<int>(
                              stream: isCheckedIn ? _timerStream() : null,
                              builder: (context, snap) {
                                Duration elapsed = Duration.zero;
                                if (isCheckedIn && startTs > 0) {
                                  final nowTs = snap.data ??
                                      DateTime.now().millisecondsSinceEpoch;
                                  final diff = nowTs - startTs;
                                  if (diff > 0) {
                                    elapsed = Duration(milliseconds: diff);
                                  }
                                }

                                return Row(
                                  children: [
                                    Container(
                                      width: Responsive.h(7.5),
                                      height: Responsive.h(7.5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCheckedIn
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(width: Responsive.h(7)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isCheckedIn
                                                ? _format(elapsed)
                                                : "Not In",
                                            style: TextStyle(
                                              fontSize: Responsive.h(12.5),
                                              fontWeight: FontWeight.w600,
                                              color: isCheckedIn
                                                  ? Colors.white
                                                  : const Color(0xFF94A3B8),
                                              letterSpacing:
                                                  isCheckedIn ? 0.3 : 0,
                                            ),
                                          ),
                                          Text(
                                            isCheckedIn
                                                ? "Active Session"
                                                : "Attendance",
                                            style: TextStyle(
                                              fontSize: Responsive.h(9.5),
                                              color: isCheckedIn
                                                  ? const Color(0xFF4ADE80)
                                                  : const Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          /// PUNCH BUTTON
                          InkWell(
                            onTap: isLoading
                                ? null
                                : () {
                                    context
                                        .read<CheckInBloc>()
                                        .add(ToggleCheckIn());
                                  },
                            borderRadius:
                                BorderRadius.circular(Responsive.h(8)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.h(8),
                                vertical: Responsive.h(6),
                              ),
                              decoration: BoxDecoration(
                                color: isCheckedIn
                                    ? const Color(0xFFC84804)
                                    : const Color(0xFF2563EB),
                                borderRadius:
                                    BorderRadius.circular(Responsive.h(8)),
                                border: Border.all(
                                  color: isCheckedIn
                                      ? const Color(0xFFDD5B01)
                                      : const Color(0xFF3B82F6),
                                  width: 1,
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: Responsive.h(13),
                                      height: Responsive.h(13),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCheckedIn
                                              ? Icons.logout_rounded
                                              : Icons.touch_app_rounded,
                                          size: Responsive.h(14),
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: Responsive.h(4)),
                                        Text(
                                          isCheckedIn ? "Check Out" : "Check In",
                                          style: TextStyle(
                                            fontSize: Responsive.h(11),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
