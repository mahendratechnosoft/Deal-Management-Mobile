import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/timesheet/block/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/block/timesheet_event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/event.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';

import '../../features/auth/bloc/user_role.dart';
import '../../features/auth/data/locale_data/hive_service.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// REQUIRED
  final String title;

  /// OPTIONAL
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.bottom,
  });

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class _CommonAppBarState extends State<CommonAppBar> {
  late final String today;
  final user = AuthLocalStorage.getUser();
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final role = RoleResolver.rolePath;

  @override
  void initState() {
    super.initState();
    today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    /// 🔥 API call only once (SAFE)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckInBloc>().add(
            CheckInUserEvent(
              fromDate: currentDate,
              toDate: currentDate,
              employeeId: user?.employeeId ?? '',
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: widget.centerTitle,
      backgroundColor: widget.backgroundColor ?? AppColors.primaryDark,
      elevation: widget.elevation,
      iconTheme: IconThemeData(
        color: widget.iconColor ?? AppColors.background,
      ),
      leading: widget.leading,
      actions: [
        /// 🔔 Notification Icon

        /// ▶️ / ⏸️ Check-In – Check-Out Button
        /// ▶️ / ⏸️ Check-In – Check-Out Button
        role == 'employee'
            ? BlocSelector<CheckInBloc, CheckInUserState, bool>(
                selector: (state) =>
                    state is CheckInLoaded ? state.isCheckedIn : false,
                builder: (context, isCheckedIn) {
                  log('status check: $isCheckedIn');

                  return IconButton(
                    onPressed: () async {
                      /// 🔥 ONLY toggle (no delay, no refetch)
                      context
                          .read<TimeSheetBloc>()
                          .add(CheckStatusEvent(!isCheckedIn));
                      await Future.delayed(Duration(seconds: 1));
                      context.read<CheckInBloc>().add(
                            CheckInUserEvent(
                              fromDate: currentDate,
                              toDate: currentDate,
                              employeeId: user?.employeeId ?? '',
                            ),
                          );
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Stack(
                        alignment: Alignment.center,
                        key: ValueKey(isCheckedIn),
                        children: [
                          Icon(
                            isCheckedIn ? Icons.circle : Icons.circle,
                            color: isCheckedIn ? AppColors.success : Colors.red,
                            size: Responsive.sp(36),
                          ),

                          /// 🔤 IN / OUT TEXT
                          Text(
                            isCheckedIn ? 'IN' : 'OUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const SizedBox.shrink(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications),
        ),

        const SizedBox(width: 10),
      ],
      bottom: widget.bottom,
      title: Text(
        widget.title,
        style: widget.titleStyle ??
            TextStyle(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.sp(20),
            ),
      ),
    );
  }
}
