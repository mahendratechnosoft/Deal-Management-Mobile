import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/drawer/presentation/custom_drawer.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_bloc.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_event.dart';
import 'package:xpertbiz/features/timesheet/bloc/timesheet_state.dart';
import 'package:xpertbiz/features/timesheet/data/model/calendar_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/employee_item_model.dart';
import 'package:xpertbiz/features/timesheet/presentation/attendance_mark.dart';
import 'package:xpertbiz/features/timesheet/presentation/emp_list_screen.dart';

class MonthlyTimesheetScreen extends StatefulWidget {
  const MonthlyTimesheetScreen({super.key});

  @override
  State<MonthlyTimesheetScreen> createState() => _MonthlyTimesheetScreenState();
}

class _MonthlyTimesheetScreenState extends State<MonthlyTimesheetScreen> {
  DateTime _selectedMonth = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _mainVerticalController = ScrollController();

  bool _showCheckInCard = true;
  bool _isSyncingScroll = false;
  bool _isListView = false;

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

  void _loadData() {
    context
        .read<TimeSheetBloc>()
        .add(FetchMonthlyTimesheetGrid(_selectedMonth));
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _loadData();
  }

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'SELECT MONTH',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = RoleResolver.rolePath;

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: 'Timesheet',
        actions: [
          IconButton(
            tooltip: _isListView ? 'Switch to Grid View' : 'Switch to List View',
            icon: Icon(
              _isListView ? Icons.grid_on_rounded : Icons.view_list_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isListView
          ? const EmployeeListScreen()
          : BlocBuilder<TimeSheetBloc, TimeSheetState>(
              builder: (context, state) {
                if (state is TimeSheetLoading && state is! TimeSheetLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.error),
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
                      // 1. Employee Check-In / Check-Out Widget (Collapsible Card)
                      _buildCheckInHeader(role),

                      // 2. Month Selector & Search Controls
                      _buildControls(employees.length),

                      // 3. Legend Bar (P, A, W, H)
                      _buildLegendBar(),

                      // 4. Monthly Grid View
                      Expanded(
                        child: isGridLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.error,
                                ),
                              )
                            : employees.isEmpty
                                ? _buildEmptyEmployees()
                                : _buildTimesheetGrid(
                                    employees: employees,
                                    calendarMap: calendarMap,
                                    monthlyAttendance: monthlyAttendance,
                                  ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// 🕒 Check-In / Check-Out Section at the top
  Widget _buildCheckInHeader(String role) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      size: 18,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Quick Attendance Punch",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showCheckInCard
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          if (_showCheckInCard)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: CheckInOutWidget(
                onStatusChanged: () {
                  // Reload grid to update today's status
                  _loadData();
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 📅 Month Selector and Search Bar
  Widget _buildControls(int count) {
    final monthFormat = DateFormat('MMMM yyyy');
    final formattedMonth = monthFormat.format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Previous Month Button
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left_rounded, size: 24),
                color: const Color(0xFF334155),
                onPressed: _previousMonth,
              ),

              // Month Display & Picker
              Expanded(
                child: InkWell(
                  onTap: _pickMonthYear,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedMonth,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Next Month Button
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right_rounded, size: 24),
                color: const Color(0xFF334155),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Search Filter Input
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
      ),
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
            border: Border.all(color: textColor.withOpacity(0.3), width: 0.8),
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

  /// 📊 The Matrix Timesheet Grid
  Widget _buildTimesheetGrid({
    required List<EmployeeItemModel> employees,
    required Map<String, CalendarModel> calendarMap,
    required EmpMonthAttendanceModel? monthlyAttendance,
  }) {
    final int daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final today = DateTime.now();
    final bool isCurrentMonth =
        _selectedMonth.year == today.year && _selectedMonth.month == today.month;

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
                      const Icon(Icons.people_alt_rounded,
                          size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        'Employee (${employees.length})',
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
                      children: List.generate(daysInMonth, (index) {
                        final int day = index + 1;
                        final date = DateTime(
                            _selectedMonth.year, _selectedMonth.month, day);
                        final dateKey = DateFormat('yyyy-MM-dd').format(date);
                        final isWeekend = calendarMap[dateKey]?.isWeekend ==
                                true ||
                            (calendarMap[dateKey] == null &&
                                date.weekday == DateTime.sunday);
                        final isHoliday =
                            calendarMap[dateKey]?.isHoliday == true;
                        final isTodayCell = isCurrentMonth && day == today.day;
                        final weekdayStr = DateFormat('E').format(date);

                        return Container(
                          width: _dayCellWidth,
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
                                day.toString().padLeft(2, '0'),
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
                                weekdayStr.substring(0, 1),
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
                      }),
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
                        children: List.generate(daysInMonth, (index) {
                          final int day = index + 1;
                          final date = DateTime(
                              _selectedMonth.year, _selectedMonth.month, day);
                          final cellData = _evaluateAttendanceCell(
                            employee: emp,
                            date: date,
                            calendarMap: calendarMap,
                            monthlyAttendance: monthlyAttendance,
                          );

                          return InkWell(
                            onTap: () => _showCellDetails(context, emp, date, cellData),
                            child: Container(
                              width: _dayCellWidth,
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
                        }),
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

    // Fallback: if calendarMap is missing weekend entry, Sunday is always weekend
    final bool isWeekend = isCalWeekend ||
        (calEntry == null && date.weekday == DateTime.sunday);

    if (isWeekend) {
      return _CellStatusData(
        code: 'W',
        title: 'Weekend',
        description: calEntry?.description ?? 'Weekly Off',
        isWeekend: true,
        isFuture: isFuture,
      );
    }

    if (isCalHoliday) {
      return _CellStatusData(
        code: 'H',
        title: 'Company Holiday',
        description: calEntry?.description ?? 'Public Holiday',
        isHoliday: true,
        isFuture: isFuture,
      );
    }

    if (isFuture) {
      return _CellStatusData(
        code: '-',
        title: 'Future Date',
        description: 'Working Day',
        isFuture: true,
      );
    }

    // Check attendance records
    final empAttendance = monthlyAttendance?.data[employee.name];
    final records = empAttendance?[dateKey] ?? [];

    if (records.isNotEmpty) {
      // Calculate work duration
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

    // Past or today working day with no punch
    return _CellStatusData(
      code: 'A',
      title: 'Absent',
      description: 'No check-in recorded',
      isToday: isToday,
    );
  }

  String _formatWorkDuration(Duration d) {
    if (d.inMinutes <= 0) return "Checked in";
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return "${h}h ${m}m";
  }

  /// 💬 Punch details bottom sheet on cell tap
  void _showCellDetails(
    BuildContext context,
    EmployeeItemModel employee,
    DateTime date,
    _CellStatusData data,
  ) {
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(date);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

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
                              : (data.code == 'H' ? Colors.blue : Colors.red)),
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
                      Text(
                        _formatWorkDuration(data.totalDuration!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                  ],
                ),
              ),

              // Punches Timeline (if any)
              if (data.records.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  "Punches Recorded",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: data.records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final punch = data.records[i];
                      final punchTime = DateTime.fromMillisecondsSinceEpoch(
                          punch.timeStamp);
                      final timeStr =
                          DateFormat('hh:mm a').format(punchTime);

                      return Row(
                        children: [
                          Icon(
                            punch.status
                                ? Icons.arrow_circle_right_rounded
                                : Icons.arrow_circle_left_rounded,
                            size: 16,
                            color:
                                punch.status ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            punch.status ? 'Check In' : 'Check Out',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: punch.status
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
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
