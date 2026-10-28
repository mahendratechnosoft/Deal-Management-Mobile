import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/di/injection_container.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/drawer/presentation/custom_drawer.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_event.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_state.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/bloc.dart';
import 'package:xpertbiz/features/timesheet/checInUser_bloc/state.dart';
import 'package:xpertbiz/features/timesheet/data/model/calendar_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/employee_item_model.dart';
import 'package:xpertbiz/features/timesheet/data/repo/repo.dart';
import 'package:xpertbiz/features/timesheet/presentation/attendance_mark.dart';

enum TimesheetFilterMode { monthly, weekly, daily }

class MonthlyTimesheetScreen extends StatefulWidget {
  const MonthlyTimesheetScreen({super.key});

  @override
  State<MonthlyTimesheetScreen> createState() => _MonthlyTimesheetScreenState();
}

class _MonthlyTimesheetScreenState extends State<MonthlyTimesheetScreen> {
  DateTime _selectedDate = DateTime.now();
  TimesheetFilterMode _viewMode = TimesheetFilterMode.monthly;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _mainVerticalController = ScrollController();

  bool _showCheckInCard = false;
  bool _isSyncingScroll = false;

  final double _employeeColWidth = 140.0;
  final double _dayCellWidth = 44.0;
  final double _cellHeight = 46.0;

  @override
  void initState() {
    super.initState();

    // Link horizontal scrolling between header and body
    _headerHorizontalController.addListener(() {
      if (_isSyncingScroll) return;
      _isSyncingScroll = true;
      if (_bodyHorizontalController.hasClients) {
        _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
      }
      _isSyncingScroll = false;
    });

    _bodyHorizontalController.addListener(() {
      if (_isSyncingScroll) return;
      _isSyncingScroll = true;
      if (_headerHorizontalController.hasClients) {
        _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
      }
      _isSyncingScroll = false;
    });

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _mainVerticalController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(const Duration(days: 6));
  }

  List<DateTime> _getDaysInView() {
    switch (_viewMode) {
      case TimesheetFilterMode.monthly:
        final daysInMonth =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        return List.generate(
          daysInMonth,
          (i) => DateTime(_selectedDate.year, _selectedDate.month, i + 1),
        );
      case TimesheetFilterMode.weekly:
        final start = _getStartOfWeek(_selectedDate);
        return List.generate(7, (i) => start.add(Duration(days: i)));
      case TimesheetFilterMode.daily:
        return [
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        ];
    }
  }

  String _getWeeklyTitle(DateTime date) {
    final start = _getStartOfWeek(date);
    final end = _getEndOfWeek(date);
    if (start.month == end.month && start.year == end.year) {
      return "${DateFormat('dd').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
    } else if (start.year == end.year) {
      return "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
    } else {
      return "${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
    }
  }

  String _getDailyTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      return "Today, ${DateFormat('dd MMM yyyy').format(date)}";
    } else if (target == today.subtract(const Duration(days: 1))) {
      return "Yesterday, ${DateFormat('dd MMM yyyy').format(date)}";
    } else if (target == today.add(const Duration(days: 1))) {
      return "Tomorrow, ${DateFormat('dd MMM yyyy').format(date)}";
    }
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  void _loadData() {
    String startDate;
    String endDate;

    switch (_viewMode) {
      case TimesheetFilterMode.monthly:
        final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        startDate = DateFormat('yyyy-MM-dd').format(start);
        endDate = DateFormat('yyyy-MM-dd').format(end);
        break;
      case TimesheetFilterMode.weekly:
        final start = _getStartOfWeek(_selectedDate);
        final end = _getEndOfWeek(_selectedDate);
        startDate = DateFormat('yyyy-MM-dd').format(start);
        endDate = DateFormat('yyyy-MM-dd').format(end);
        break;
      case TimesheetFilterMode.daily:
        startDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
        endDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
        break;
    }

    context.read<TimeSheetBloc>().add(
          FetchMonthlyTimesheetGrid(
            _selectedDate,
            customStartDate: startDate,
            customEndDate: endDate,
          ),
        );
  }

  void _onPrevious() {
    setState(() {
      switch (_viewMode) {
        case TimesheetFilterMode.monthly:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
        case TimesheetFilterMode.weekly:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case TimesheetFilterMode.daily:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
      }
    });
    _loadData();
  }

  void _onNext() {
    setState(() {
      switch (_viewMode) {
        case TimesheetFilterMode.monthly:
          _selectedDate =
              DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
          break;
        case TimesheetFilterMode.weekly:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case TimesheetFilterMode.daily:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
      }
    });
    _loadData();
  }

  Future<void> _pickPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: _viewMode == TimesheetFilterMode.monthly
          ? 'SELECT MONTH'
          : (_viewMode == TimesheetFilterMode.weekly
              ? 'SELECT WEEK'
              : 'SELECT DATE'),
    );
    if (picked != null) {
      setState(() {
        if (_viewMode == TimesheetFilterMode.monthly) {
          _selectedDate = DateTime(picked.year, picked.month, 1);
        } else {
          _selectedDate = picked;
        }
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthLocalStorage.getUser();
    final bool hasAccess = user?.moduleAccess.timeSheetAccess ?? false;
    final bool canViewAll = user?.moduleAccess.timeSheetViewAll ?? false;
    final bool canCreate = user?.moduleAccess.timeSheetCreate ?? false;
    final bool canEdit = user?.moduleAccess.timeSheetEdit ?? false;
    final bool canDelete = user?.moduleAccess.timeSheetDelete ?? false;
    final role = RoleResolver.rolePath;

    // 🔒 1. Module Access: timeSheetAccess check
    if (!hasAccess) {
      return Scaffold(
        drawer: const CustomDrawer(),
        appBar: CommonAppBar(title: 'Timesheet'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have permission to access the Timesheet module.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenTitle = canViewAll ? 'Timesheet' : 'My Timesheet';

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(
        title: screenTitle,
      ),
      body: BlocBuilder<TimeSheetBloc, TimeSheetState>(
        builder: (context, state) {
          if (state is TimeSheetLoading && state is! TimeSheetLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is TimeSheetError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 56, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state is TimeSheetLoaded ? state : null;
          final employees = loadedState?.filteredEmployeeList ?? [];
          final calendarMap = loadedState?.calendarMap ?? {};
          final monthlyAttendance = loadedState?.monthlyAttendance;
          final isGridLoading = loadedState?.isGridLoading ?? false;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: Column(
              children: [
                // 1. Employee Attendance Punch Bar (Only for Employee role, collapsed by default)
                _buildCheckInHeader(role: role, canCheckIn: hasAccess),

                // 2. Filter Pills (Monthly/Weekly/Daily) + Period Selector + Search
                _buildControls(
                  count: employees.length,
                  canViewAll: canViewAll,
                ),

                // 3. Status Legend Bar (P, A, W, H)
                _buildLegendBar(),

                // 4. Timesheet View (Grid for Monthly/Weekly, Daily List for Daily)
                Expanded(
                  child: isGridLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : employees.isEmpty
                          ? _buildEmptyEmployees()
                          : (_viewMode == TimesheetFilterMode.daily
                              ? _buildDailyView(
                                  employees: employees,
                                  calendarMap: calendarMap,
                                  monthlyAttendance: monthlyAttendance,
                                  canViewAll: canViewAll,
                                  canCreate: canCreate,
                                  canEdit: canEdit,
                                  canDelete: canDelete,
                                )
                              : _buildTimesheetGrid(
                                  employees: employees,
                                  daysInView: _getDaysInView(),
                                  calendarMap: calendarMap,
                                  monthlyAttendance: monthlyAttendance,
                                  canViewAll: canViewAll,
                                  canCreate: canCreate,
                                  canEdit: canEdit,
                                  canDelete: canDelete,
                                )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🕒 Attendance Punch Section (ONLY for Employee role)
  Widget _buildCheckInHeader({required String role, required bool canCheckIn}) {
    if (role != 'employee' || !canCheckIn) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showCheckInCard = !_showCheckInCard;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: BlocBuilder<CheckInBloc, CheckInUserState>(
                builder: (context, checkInState) {
                  final bool isCheckedIn =
                      checkInState is CheckInLoaded && checkInState.isCheckedIn;

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isCheckedIn
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fingerprint_rounded,
                          size: 18,
                          color: isCheckedIn
                              ? const Color(0xFF166534)
                              : const Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Attendance Punch',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isCheckedIn
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCheckedIn
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCheckedIn
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCheckedIn ? "Checked In" : "Not In",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isCheckedIn
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        _showCheckInCard
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF64748B),
                        size: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (_showCheckInCard) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: CheckInOutWidget(
                onStatusChanged: () {
                  _loadData();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📅 Month/Week/Day Filter Pills, Period Selector and Search Bar
  Widget _buildControls({required int count, required bool canViewAll}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      color: Colors.white,
      child: Column(
        children: [
          // 1. Segmented Filter (Monthly | Weekly | Daily)
          _buildFilterSegment(),

          const SizedBox(height: 6),

          // 2. Date Navigator (< Title >)
          _buildDateNavigator(),

          // 3. Search Filter Input (only needed when user can view all employees)
          if (canViewAll) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  context
                      .read<TimeSheetBloc>()
                      .add(FilterTimesheetEmployees(val));
                },
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search employee by name ($count found)...',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<TimeSheetBloc>()
                                .add(const FilterTimesheetEmployees(''));
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 🔘 Filter Pills (Monthly / Weekly / Daily)
  Widget _buildFilterSegment() {
    final modes = [
      {
        'mode': TimesheetFilterMode.monthly,
        'label': 'Monthly',
        'icon': Icons.calendar_month_rounded
      },
      {
        'mode': TimesheetFilterMode.weekly,
        'label': 'Weekly',
        'icon': Icons.view_week_rounded
      },
      {
        'mode': TimesheetFilterMode.daily,
        'label': 'Daily',
        'icon': Icons.today_rounded
      },
    ];

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: modes.map((item) {
          final mode = item['mode'] as TimesheetFilterMode;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;
          final bool isSelected = _viewMode == mode;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (_viewMode == mode) return;
                setState(() {
                  _viewMode = mode;
                });
                _loadData();
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.22),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 13,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 📅 Date Navigator (< Title >)
  Widget _buildDateNavigator() {
    String title;
    switch (_viewMode) {
      case TimesheetFilterMode.monthly:
        title = DateFormat('MMMM yyyy').format(_selectedDate);
        break;
      case TimesheetFilterMode.weekly:
        title = _getWeeklyTitle(_selectedDate);
        break;
      case TimesheetFilterMode.daily:
        title = _getDailyTitle(_selectedDate);
        break;
    }

    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_left_rounded, size: 24),
          color: const Color(0xFF334155),
          onPressed: _onPrevious,
        ),
        Expanded(
          child: InkWell(
            onTap: _pickPeriod,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_right_rounded, size: 24),
          color: const Color(0xFF334155),
          onPressed: _onNext,
        ),
      ],
    );
  }

  /// 🏷️ Status Legend (P, A, W, H)
  Widget _buildLegendBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('P', 'Present', const Color(0xFFDCFCE7),
              const Color(0xFF166534)),
          _buildLegendItem(
              'A', 'Absent', const Color(0xFFFFE4E6), const Color(0xFF991B1B)),
          _buildLegendItem(
              'W', 'Weekend', const Color(0xFFF1F5F9), const Color(0xFF475569)),
          _buildLegendItem(
              'H', 'Holiday', const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String code, String label, Color bgColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: textColor.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Text(
            code,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  /// 📋 Daily Attendance List View
  Widget _buildDailyView({
    required List<EmployeeItemModel> employees,
    required Map<String, CalendarModel> calendarMap,
    required EmpMonthAttendanceModel? monthlyAttendance,
    required bool canViewAll,
    required bool canEdit,
    required bool canCreate,
    required bool canDelete,
  }) {
    final date =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
      itemCount: employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final emp = employees[index];
        final cellData = _evaluateAttendanceCell(
          employee: emp,
          date: date,
          calendarMap: calendarMap,
          monthlyAttendance: monthlyAttendance,
        );

        final initials = emp.name.trim().isNotEmpty
            ? emp.name
                .trim()
                .split(' ')
                .map((w) => w.isNotEmpty ? w[0] : '')
                .take(2)
                .join()
                .toUpperCase()
            : '?';

        // Extract punch in & out strings
        String inTimeStr = '-';
        String outTimeStr = '-';
        if (cellData.records.isNotEmpty) {
          final inPunches = cellData.records.where((r) => r.status).toList();
          final outPunches = cellData.records.where((r) => !r.status).toList();
          if (inPunches.isNotEmpty) {
            inTimeStr = DateFormat('hh:mm a').format(
              DateTime.fromMillisecondsSinceEpoch(inPunches.first.timeStamp),
            );
          }
          if (outPunches.isNotEmpty) {
            outTimeStr = DateFormat('hh:mm a').format(
              DateTime.fromMillisecondsSinceEpoch(outPunches.last.timeStamp),
            );
          }
        }

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _showCellDetails(
              context: context,
              employee: emp,
              date: date,
              data: cellData,
              canCreate: canCreate,
              canEdit: canEdit,
              canDelete: canDelete,
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.login_rounded,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              inTimeStr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: inTimeStr != '-'
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.logout_rounded,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              outTimeStr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: outTimeStr != '-'
                                    ? const Color(0xFF991B1B)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(cellData),
                      if (cellData.totalDuration != null &&
                          cellData.totalDuration!.inMinutes > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          _formatWorkDuration(cellData.totalDuration!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📊 The Matrix Timesheet Grid (for Monthly and Weekly views)
  Widget _buildTimesheetGrid({
    required List<EmployeeItemModel> employees,
    required List<DateTime> daysInView,
    required Map<String, CalendarModel> calendarMap,
    required EmpMonthAttendanceModel? monthlyAttendance,
    required bool canViewAll,
    required bool canCreate,
    required bool canEdit,
    required bool canDelete,
  }) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final double colWidth =
        _viewMode == TimesheetFilterMode.weekly ? 52.0 : _dayCellWidth;

    return SingleChildScrollView(
      controller: _mainVerticalController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Sticky Top Headers Row
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
              ),
            ),
            child: Row(
              children: [
                // Left Sticky Header: "Employee"
                Container(
                  width: _employeeColWidth,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    border: Border(
                      right: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        canViewAll
                            ? Icons.people_alt_rounded
                            : Icons.person_rounded,
                        size: 15,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        canViewAll
                            ? 'Employee (${employees.length})'
                            : 'My Timesheet',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Scrollable Days Header (Day 1..N)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: daysInView.map((date) {
                        final dateKey = DateFormat('yyyy-MM-dd').format(date);
                        final isWeekend = calendarMap[dateKey]?.isWeekend ==
                                true ||
                            (calendarMap[dateKey] == null &&
                                date.weekday == DateTime.sunday);
                        final isHoliday =
                            calendarMap[dateKey]?.isHoliday == true;
                        final isTodayCell =
                            DateTime(date.year, date.month, date.day) ==
                                todayDate;
                        final weekdayStr = DateFormat('E').format(date);

                        return Container(
                          width: colWidth,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isTodayCell
                                ? const Color(0xFFEEF2FF)
                                : (isWeekend
                                    ? const Color(0xFFF1F5F9)
                                    : Colors.transparent),
                            border: Border(
                              right: const BorderSide(
                                  color: Color(0xFFE2E8F0), width: 0.8),
                              bottom: isTodayCell
                                  ? const BorderSide(
                                      color: Color(0xFF4F46E5), width: 2.5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                date.day.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isTodayCell
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: isTodayCell
                                      ? const Color(0xFF4F46E5)
                                      : (isHoliday
                                          ? const Color(0xFF1D4ED8)
                                          : (isWeekend
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF1E293B))),
                                ),
                              ),
                              Text(
                                _viewMode == TimesheetFilterMode.weekly
                                    ? weekdayStr
                                    : weekdayStr.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isTodayCell
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Matrix Body: Left Employee Column + Right Horizontally Scrollable Cells
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Left Column: Employee Names
              Container(
                width: _employeeColWidth,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                ),
                child: Column(
                  children: employees.map((emp) {
                    final initials = emp.name.trim().isNotEmpty
                        ? emp.name
                            .trim()
                            .split(' ')
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                        : '?';

                    return Container(
                      height: _cellHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFF1F5F9), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFF4F46E5),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              emp.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Horizontally Scrollable Cells
              Expanded(
                child: SingleChildScrollView(
                  controller: _bodyHorizontalController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: employees.map((emp) {
                      return Row(
                        children: daysInView.map((date) {
                          final cellData = _evaluateAttendanceCell(
                            employee: emp,
                            date: date,
                            calendarMap: calendarMap,
                            monthlyAttendance: monthlyAttendance,
                          );

                          return InkWell(
                            onTap: () => _showCellDetails(
                              context: context,
                              employee: emp,
                              date: date,
                              data: cellData,
                              canCreate: canCreate,
                              canEdit: canEdit,
                              canDelete: canDelete,
                            ),
                            child: Container(
                              width: colWidth,
                              height: _cellHeight,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Color(0xFFF1F5F9), width: 1),
                                  bottom: BorderSide(
                                      color: Color(0xFFF1F5F9), width: 1),
                                ),
                              ),
                              child: _buildStatusBadge(cellData),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 🏷️ Render Cell Badge (A, P, W, H, -)
  Widget _buildStatusBadge(_CellStatusData data) {
    if (data.code == '-') {
      return const Text(
        '-',
        style: TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    Color bgColor;
    Color textColor;

    switch (data.code) {
      case 'P':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 'A':
        bgColor = const Color(0xFFFFE4E6);
        textColor = const Color(0xFF991B1B);
        break;
      case 'W':
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        break;
      case 'H':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1D4ED8);
        break;
      default:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF64748B);
    }

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        data.code,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  /// 🧠 Evaluate attendance status for employee on a given day
  _CellStatusData _evaluateAttendanceCell({
    required EmployeeItemModel employee,
    required DateTime date,
    required Map<String, CalendarModel> calendarMap,
    required EmpMonthAttendanceModel? monthlyAttendance,
  }) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDay = DateTime(date.year, date.month, date.day);
    final bool isFuture = currentDay.isAfter(today);
    final bool isToday = currentDay.isAtSameMomentAs(today);

    final calEntry = calendarMap[dateKey];
    final bool isCalWeekend = calEntry?.isWeekend == true;
    final bool isCalHoliday = calEntry?.isHoliday == true;

    final bool isWeekend = isCalWeekend ||
        (calEntry == null && date.weekday == DateTime.sunday);

    final empAttendance = monthlyAttendance?.data[employee.name];
    final records = empAttendance?[dateKey] ?? [];

    Duration total = Duration.zero;
    DateTime? lastIn;

    for (final r in records) {
      final t = DateTime.fromMillisecondsSinceEpoch(r.timeStamp);
      if (r.status) {
        lastIn = t;
      } else if (lastIn != null) {
        total += t.difference(lastIn);
        lastIn = null;
      }
    }

    if (isToday && lastIn != null) {
      total += DateTime.now().difference(lastIn);
    }

    if (isWeekend) {
      if (records.isNotEmpty) {
        return _CellStatusData(
          code: 'P',
          title: 'Present (Weekend)',
          description: _formatWorkDuration(total),
          records: records,
          totalDuration: total,
          isWeekend: true,
          isFuture: isFuture,
          isToday: isToday,
        );
      }
      return _CellStatusData(
        code: 'W',
        title: 'Weekend',
        description: calEntry?.description ?? 'Weekly Off',
        isWeekend: true,
        isFuture: isFuture,
        records: records,
      );
    }

    if (isCalHoliday) {
      if (records.isNotEmpty) {
        return _CellStatusData(
          code: 'P',
          title: 'Present (Holiday)',
          description: _formatWorkDuration(total),
          records: records,
          totalDuration: total,
          isHoliday: true,
          isFuture: isFuture,
          isToday: isToday,
        );
      }
      return _CellStatusData(
        code: 'H',
        title: 'Company Holiday',
        description: calEntry?.description ?? 'Public Holiday',
        isHoliday: true,
        isFuture: isFuture,
        records: records,
      );
    }

    if (isFuture) {
      if (records.isNotEmpty) {
        return _CellStatusData(
          code: 'P',
          title: 'Present',
          description: _formatWorkDuration(total),
          records: records,
          totalDuration: total,
          isFuture: true,
        );
      }
      return _CellStatusData(
        code: '-',
        title: 'Future Date',
        description: 'Working Day',
        isFuture: true,
        records: records,
      );
    }

    if (records.isNotEmpty) {
      final hasPunch = records.any((r) => r.status);
      if (hasPunch || total.inMinutes > 0) {
        return _CellStatusData(
          code: 'P',
          title: 'Present',
          description: _formatWorkDuration(total),
          records: records,
          totalDuration: total,
          isToday: isToday,
        );
      }
    }

    return _CellStatusData(
      code: 'A',
      title: 'Absent',
      description: 'No check-in recorded',
      records: records,
      isToday: isToday,
    );
  }

  String _formatWorkDuration(Duration d) {
    if (d.inMinutes <= 0) return "Checked in";
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return "${h}h ${m}m";
  }

  /// 🔄 Group raw punches into paired work sessions
  List<WorkSession> _groupRecordsIntoSessions(List<Attendance> records) {
    final sorted = List<Attendance>.from(records)
      ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));

    final List<WorkSession> sessions = [];
    Attendance? pendingIn;

    for (final r in sorted) {
      if (r.status) {
        if (pendingIn != null) {
          sessions.add(
            WorkSession(
              sessionIndex: sessions.length + 1,
              checkIn: pendingIn,
              checkOut: null,
            ),
          );
        }
        pendingIn = r;
      } else {
        if (pendingIn != null) {
          sessions.add(
            WorkSession(
              sessionIndex: sessions.length + 1,
              checkIn: pendingIn,
              checkOut: r,
            ),
          );
          pendingIn = null;
        } else {
          sessions.add(
            WorkSession(
              sessionIndex: sessions.length + 1,
              checkIn: null,
              checkOut: r,
            ),
          );
        }
      }
    }

    if (pendingIn != null) {
      sessions.add(
        WorkSession(
          sessionIndex: sessions.length + 1,
          checkIn: pendingIn,
          checkOut: null,
        ),
      );
    }

    return sessions;
  }

  /// 💬 Punch details bottom sheet on cell tap
  void _showCellDetails({
    required BuildContext context,
    required EmployeeItemModel employee,
    required DateTime date,
    required _CellStatusData data,
    required bool canCreate,
    required bool canEdit,
    required bool canDelete,
  }) {
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final user = AuthLocalStorage.getUser();
    final myEmpId = user?.employeeId ?? '';
    final bool allowCreate = canCreate;
    final bool allowEdit = canEdit;
    final bool allowDelete = canDelete;

    final sessions = _groupRecordsIntoSessions(data.records);
    final bool defaultNextStatus =
        data.records.isEmpty || !data.records.last.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetCtx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Employee Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF4F46E5),
                      child: Text(
                        employee.name.isNotEmpty ? employee.name[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(data),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Status Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        data.code == 'P'
                            ? Icons.check_circle_rounded
                            : (data.code == 'W'
                                ? Icons.weekend_rounded
                                : (data.code == 'H'
                                    ? Icons.celebration_rounded
                                    : Icons.cancel_rounded)),
                        color: data.code == 'P'
                            ? Colors.green
                            : (data.code == 'W'
                                ? Colors.grey
                                : (data.code == 'H'
                                    ? Colors.blue
                                    : Colors.red)),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              data.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (data.totalDuration != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Total: ${_formatWorkDuration(data.totalDuration!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sessions Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Work Sessions",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                        if (sessions.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${sessions.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (allowCreate)
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddPunchDialog(
                            parentContext: context,
                            employee: employee,
                            date: date,
                            records: data.records,
                            onSuccess: () {
                              Navigator.pop(bottomSheetCtx);
                              _loadData();
                            },
                          );
                        },
                        icon: Icon(
                          defaultNextStatus
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          size: 15,
                        ),
                        label: Text(
                          defaultNextStatus ? 'Check In' : 'Check Out',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: defaultNextStatus
                              ? const Color(0xFF059669)
                              : const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Sessions List or Empty State
                Expanded(
                  child: sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                data.code == 'W'
                                    ? Icons.weekend_outlined
                                    : Icons.access_time_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                data.code == 'W'
                                    ? 'No punches for this weekend day'
                                    : 'No attendance recorded for this day',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "+ Check In" to record attendance',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            return _buildSessionCard(
                              context: context,
                              session: sessions[i],
                              date: date,
                              employee: employee,
                              allowEdit: allowEdit,
                              allowDelete: allowDelete,
                              onRefresh: () {
                                Navigator.pop(bottomSheetCtx);
                                _loadData();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📇 Render a work session card with connected In/Out and duration in between
  Widget _buildSessionCard({
    required BuildContext context,
    required WorkSession session,
    required DateTime date,
    required EmployeeItemModel employee,
    required bool allowEdit,
    required bool allowDelete,
    required VoidCallback onRefresh,
  }) {
    final checkInTimeStr = session.checkIn != null
        ? DateFormat('hh:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(session.checkIn!.timeStamp))
        : 'Missing Check-in';

    final checkOutTimeStr = session.checkOut != null
        ? DateFormat('hh:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(session.checkOut!.timeStamp))
        : (session.checkIn != null ? 'Not Checked Out' : 'Missing Check-out');

    final duration = session.duration;
    final durationStr = duration != null
        ? _formatWorkDuration(duration)
        : (session.checkIn != null ? 'In Progress' : '-');

    final bool isCompleted =
        session.checkIn != null && session.checkOut != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header of Session card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Session ${session.sessionIndex}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isCompleted && session.checkIn != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                const Spacer(),
                if (allowDelete)
                  InkWell(
                    onTap: () => _confirmDeleteSession(
                      parentContext: context,
                      session: session,
                      onSuccess: onRefresh,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.red.shade600),
                          const SizedBox(width: 3),
                          Text(
                            'Delete Session',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Connected In/Out with Total Duration in Between
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Check In Row
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.login_rounded,
                          size: 16, color: Color(0xFF166534)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check In',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            checkInTimeStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: session.checkIn != null
                                  ? const Color(0xFF0F172A)
                                  : Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (session.checkIn != null && allowEdit)
                      TextButton.icon(
                        onPressed: () => _showEditPunchDialog(
                          parentContext: context,
                          employee: employee,
                          punch: session.checkIn!,
                          date: date,
                          onSuccess: onRefresh,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label:
                            const Text('Edit', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),

                // In-Between Connector with Duration Pill
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 34,
                        color: const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timelapse_rounded,
                                size: 13, color: Color(0xFF475569)),
                            const SizedBox(width: 5),
                            Text(
                              'Duration: $durationStr',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Check Out Row
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: session.checkOut != null
                            ? const Color(0xFFFFEDD5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: session.checkOut != null
                            ? const Color(0xFFC2410C)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check Out',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            checkOutTimeStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: session.checkOut != null
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (session.checkOut != null && allowEdit)
                      TextButton.icon(
                        onPressed: () => _showEditPunchDialog(
                          parentContext: context,
                          employee: employee,
                          punch: session.checkOut!,
                          date: date,
                          onSuccess: onRefresh,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label:
                            const Text('Edit', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else if (session.checkOut == null && allowEdit)
                      OutlinedButton.icon(
                        onPressed: () => _showAddPunchDialog(
                          parentContext: context,
                          employee: employee,
                          date: date,
                          records: [
                            if (session.checkIn != null) session.checkIn!,
                          ],
                          onSuccess: onRefresh,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 13),
                        label: const Text('Add Check Out',
                            style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC2410C),
                          side: const BorderSide(color: Color(0xFFFDBA74)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ➕ Add punch dialog with modern UI and strict sequence & time validation
  Future<void> _showAddPunchDialog({
    required BuildContext parentContext,
    required EmployeeItemModel employee,
    required DateTime date,
    required List<Attendance> records,
    required VoidCallback onSuccess,
  }) async {
    final sorted = List<Attendance>.from(records)
      ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    final Attendance? lastRecord = sorted.isNotEmpty ? sorted.last : null;

    // Strict Sequence:
    // Only check in if last was checkout (or 0 records).
    // Only check out if last was check in.
    final bool isCheckIn = lastRecord == null || !lastRecord.status;

    final now = DateTime.now();
    final bool isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    TimeOfDay selectedTime;
    if (isToday) {
      selectedTime = TimeOfDay.now();
    } else if (isCheckIn) {
      selectedTime = const TimeOfDay(hour: 9, minute: 0);
    } else {
      final lastDT = DateTime.fromMillisecondsSinceEpoch(lastRecord.timeStamp);
      selectedTime = TimeOfDay(
        hour: (lastDT.hour + 1).clamp(0, 23),
        minute: lastDT.minute,
      );
    }

    String? getValidationError(TimeOfDay time) {
      final candidateDT = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Cannot select time greater than current time for today
      if (isToday && candidateDT.isAfter(DateTime.now())) {
        return 'Time cannot be in the future (Current time: ${DateFormat('hh:mm a').format(DateTime.now())})';
      }

      // Cannot be earlier than last record
      if (lastRecord != null) {
        final lastDT = DateTime.fromMillisecondsSinceEpoch(lastRecord.timeStamp);
        if (candidateDT.isBefore(lastDT)) {
          return 'Time cannot be earlier than last punch (${DateFormat('hh:mm a').format(lastDT)})';
        }
      }

      return null;
    }

    bool isSubmitting = false;
    final primaryColor =
        isCheckIn ? const Color(0xFF059669) : const Color(0xFFEA580C);
    final lightBgColor =
        isCheckIn ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED);
    final borderColor =
        isCheckIn ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA);

    await showDialog(
      context: parentContext,
      barrierDismissible: !isSubmitting,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final validationError = getValidationError(selectedTime);
            final bool isValid = validationError == null;
            final formattedTime = selectedTime.format(ctx);

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🌟 Premium Gradient Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCheckIn
                              ? [
                                  const Color(0xFF047857),
                                  const Color(0xFF10B981)
                                ]
                              : [
                                  const Color(0xFFC2410C),
                                  const Color(0xFFF97316)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCheckIn
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCheckIn
                                      ? 'Record Check In'
                                      : 'Record Check Out',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isCheckIn
                                      ? 'Starting a new work session'
                                      : 'Concluding current work session',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 20),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                 Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📋 Dialog Body Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee & Date Summary Bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF4F46E5),
                                  child: Text(
                                    employee.name.isNotEmpty
                                        ? employee.name[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        DateFormat('EEEE, dd MMM yyyy')
                                            .format(date),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Enforced Sequence Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: lightBgColor,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: borderColor, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Icon(
                                    isCheckIn
                                        ? Icons.login_rounded
                                        : Icons.logout_rounded,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            isCheckIn
                                                ? 'Check In Required'
                                                : 'Check Out Required',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(Icons.lock_outline_rounded,
                                              size: 13, color: primaryColor),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lastRecord == null
                                            ? 'No punches for this day. You must Check In first.'
                                            : (lastRecord.status
                                                ? 'Last punch was Check In at ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(lastRecord.timeStamp))}. You must Check Out next.'
                                                : 'Last punch was Check Out at ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(lastRecord.timeStamp))}. You must Check In next.'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: primaryColor.withValues(
                                              alpha: 0.9),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Digital Time Selector Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: validationError != null
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFCBD5E1),
                                width: validationError != null ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'PUNCH TIME',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (isToday)
                                      Text(
                                        'Max: ${DateFormat('hh:mm a').format(DateTime.now())}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: isSubmitting
                                      ? null
                                      : () async {
                                          final picked = await showTimePicker(
                                            context: ctx,
                                            initialTime: selectedTime,
                                            helpText: isCheckIn
                                                ? 'SELECT CHECK IN TIME'
                                                : 'SELECT CHECK OUT TIME',
                                          );
                                          if (picked != null) {
                                            setState(
                                                () => selectedTime = picked);
                                          }
                                        },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.access_time_filled_rounded,
                                            color: Color(0xFF4F46E5),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 13,
                                                color: Color(0xFF4F46E5),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Change',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF4F46E5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Validation Error Box (if invalid time)
                          if (validationError != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 16, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      validationError,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.pop(dialogCtx),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: (!isValid || isSubmitting)
                                      ? null
                                      : () async {
                                          setState(() => isSubmitting = true);
                                          try {
                                            final timeStamp = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              selectedTime.hour,
                                              selectedTime.minute,
                                            ).millisecondsSinceEpoch;

                                            await sl<TimeSheetRepository>()
                                                .updateAttendance(
                                              employeeId: employee.employeeId,
                                              status: isCheckIn,
                                              timeStamp: timeStamp,
                                            );

                                            if (dialogCtx.mounted) {
                                              Navigator.pop(dialogCtx);
                                            }
                                            if (parentContext.mounted) {
                                              ScaffoldMessenger.of(
                                                      parentContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${isCheckIn ? "Check In" : "Check Out"} recorded at $formattedTime',
                                                  ),
                                                  backgroundColor:
                                                      primaryColor,
                                                ),
                                              );
                                            }
                                            onSuccess();
                                          } catch (e) {
                                            setState(
                                                () => isSubmitting = false);
                                            if (parentContext.mounted) {
                                              ScaffoldMessenger.of(
                                                      parentContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to save punch: $e'),
                                                  backgroundColor:
                                                      Colors.red.shade700,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    disabledBackgroundColor:
                                        const Color(0xFFE2E8F0),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          isCheckIn
                                              ? 'Save Check In'
                                              : 'Save Check Out',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: (!isValid || isSubmitting)
                                                ? const Color(0xFF94A3B8)
                                                : Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✏️ Edit punch dialog with modern UI and time validation
  Future<void> _showEditPunchDialog({
    required BuildContext parentContext,
    required EmployeeItemModel employee,
    required Attendance punch,
    required DateTime date,
    required VoidCallback onSuccess,
  }) async {
    final currentDT = DateTime.fromMillisecondsSinceEpoch(punch.timeStamp);
    TimeOfDay selectedTime = TimeOfDay(
      hour: currentDT.hour,
      minute: currentDT.minute,
    );

    final now = DateTime.now();
    final bool isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    String? getValidationError(TimeOfDay time) {
      final candidateDT = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Cannot select time greater than current time for today
      if (isToday && candidateDT.isAfter(DateTime.now())) {
        return 'Time cannot be in the future (Current time: ${DateFormat('hh:mm a').format(DateTime.now())})';
      }

      return null;
    }

    bool isSubmitting = false;
    final primaryColor =
        punch.status ? const Color(0xFF059669) : const Color(0xFFEA580C);

    await showDialog(
      context: parentContext,
      barrierDismissible: !isSubmitting,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final validationError = getValidationError(selectedTime);
            final bool isValid = validationError == null;
            final formattedTime = selectedTime.format(ctx);

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Gradient
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: punch.status
                              ? [
                                  const Color(0xFF047857),
                                  const Color(0xFF10B981)
                                ]
                              : [
                                  const Color(0xFFC2410C),
                                  const Color(0xFFF97316)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              punch.status
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit ${punch.status ? "Check In" : "Check Out"} Time',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Update recorded timestamp',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 20),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee & Date Summary
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF4F46E5),
                                  child: Text(
                                    employee.name.isNotEmpty
                                        ? employee.name[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        DateFormat('EEEE, dd MMM yyyy')
                                            .format(date),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Digital Time Picker Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: validationError != null
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFCBD5E1),
                                width: validationError != null ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'SELECT NEW TIME',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (isToday)
                                      Text(
                                        'Max: ${DateFormat('hh:mm a').format(DateTime.now())}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: isSubmitting
                                      ? null
                                      : () async {
                                          final picked = await showTimePicker(
                                            context: ctx,
                                            initialTime: selectedTime,
                                          );
                                          if (picked != null) {
                                            setState(
                                                () => selectedTime = picked);
                                          }
                                        },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.access_time_filled_rounded,
                                            color: Color(0xFF4F46E5),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 13,
                                                color: Color(0xFF4F46E5),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Change',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF4F46E5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Validation Error Box (if invalid time)
                          if (validationError != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 16, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      validationError,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => Navigator.pop(dialogCtx),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: (!isValid || isSubmitting)
                                      ? null
                                      : () async {
                                          setState(() => isSubmitting = true);
                                          try {
                                            final timeStamp = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              selectedTime.hour,
                                              selectedTime.minute,
                                            ).millisecondsSinceEpoch;

                                            await sl<TimeSheetRepository>()
                                                .updateAttendance(
                                              employeeId: punch
                                                      .employeeId.isNotEmpty
                                                  ? punch.employeeId
                                                  : employee.employeeId,
                                              status: punch.status,
                                              timeStamp: timeStamp,
                                              attendanceId: punch.attendanceId,
                                            );

                                            if (dialogCtx.mounted) {
                                              Navigator.pop(dialogCtx);
                                            }
                                            if (parentContext.mounted) {
                                              ScaffoldMessenger.of(
                                                      parentContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${punch.status ? "Check In" : "Check Out"} time updated to $formattedTime',
                                                  ),
                                                  backgroundColor:
                                                      primaryColor,
                                                ),
                                              );
                                            }
                                            onSuccess();
                                          } catch (e) {
                                            setState(
                                                () => isSubmitting = false);
                                            if (parentContext.mounted) {
                                              ScaffoldMessenger.of(
                                                      parentContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to update time: $e'),
                                                  backgroundColor:
                                                      Colors.red.shade700,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    disabledBackgroundColor:
                                        const Color(0xFFE2E8F0),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Update Time',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🗑️ Confirm and delete entire session
  Future<void> _confirmDeleteSession({
    required BuildContext parentContext,
    required WorkSession session,
    required VoidCallback onSuccess,
  }) async {
    bool isDeleting = false;

    await showDialog(
      context: parentContext,
      barrierDismissible: !isDeleting,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Gradient
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete Session ${session.sessionIndex}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Permanent removal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isDeleting
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 20),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFFECACA), width: 1.2),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Are you sure you want to delete this session?',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF991B1B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'This will permanently delete both check-in and check-out records for Session ${session.sessionIndex}. This action cannot be undone.',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFB91C1C),
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isDeleting
                                      ? null
                                      : () => Navigator.pop(dialogCtx),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: isDeleting
                                      ? null
                                      : () async {
                                          setState(() => isDeleting = true);
                                          try {
                                            await sl<TimeSheetRepository>()
                                                .deleteAttendanceSession(
                                                    session.attendanceIds);

                                            if (dialogCtx.mounted) {
                                              Navigator.pop(dialogCtx);
                                            }
                                            if (parentContext.mounted) {
                                              ScaffoldMessenger.of(
                                                      parentContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Session ${session.sessionIndex} deleted successfully',
                                                  ),
                                                  backgroundColor:
                                                      Colors.red.shade700,
                                                ),
                                              );
                                            }
                                            onSuccess();
                                          } catch (e) {
                                            setState(
                                                () => isDeleting = false);
                                            if (parentContext.mounted) {
                                              ScaffoldMessenger.of(
                                                      parentContext)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to delete session: $e'),
                                                  backgroundColor:
                                                      Colors.red.shade700,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                  ),
                                  child: isDeleting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Delete Session',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyEmployees() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded,
              size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            "No employees found",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try adjusting your search query",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _CellStatusData {
  final String code; // P, A, W, H, -
  final String title;
  final String description;
  final bool isWeekend;
  final bool isHoliday;
  final bool isFuture;
  final bool isToday;
  final List<Attendance> records;
  final Duration? totalDuration;

  _CellStatusData({
    required this.code,
    required this.title,
    required this.description,
    this.isWeekend = false,
    this.isHoliday = false,
    this.isFuture = false,
    this.isToday = false,
    this.records = const [],
    this.totalDuration,
  });
}

class WorkSession {
  final int sessionIndex;
  final Attendance? checkIn;
  final Attendance? checkOut;

  WorkSession({
    required this.sessionIndex,
    this.checkIn,
    this.checkOut,
  });

  Duration? get duration {
    if (checkIn != null && checkOut != null) {
      final inTime = DateTime.fromMillisecondsSinceEpoch(checkIn!.timeStamp);
      final outTime = DateTime.fromMillisecondsSinceEpoch(checkOut!.timeStamp);
      if (outTime.isAfter(inTime)) {
        return outTime.difference(inTime);
      }
    }
    return null;
  }

  List<String> get attendanceIds {
    final list = <String>[];
    if (checkIn != null && checkIn!.attendanceId.isNotEmpty) {
      list.add(checkIn!.attendanceId);
    }
    if (checkOut != null && checkOut!.attendanceId.isNotEmpty) {
      list.add(checkOut!.attendanceId);
    }
    return list;
  }
}
