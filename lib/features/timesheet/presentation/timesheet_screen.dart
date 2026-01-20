import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';
import 'package:xpertbiz/features/timesheet/widget/bottom_sheet_widget.dart';
import '../block/timesheet_bloc.dart';
import '../block/timesheet_event.dart';
import '../block/timesheet_state.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final Employee employee;
  const AttendanceCalendarScreen({super.key, required this.employee});

  @override
  State createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  final Map<String, List<Attendance>> _attendanceMap = {};

  int _presentDays = 0;
  int _absentDays = 0;
  int _halfDays = 0;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _mapApiToCalendar(EmpMonthAttendanceModel model) {
    _attendanceMap.clear();

    final empData = model.data[widget.employee.name];
    if (empData == null) return;

    empData.forEach((date, records) {
      _attendanceMap[date] = records;
    });

    _calculateMonthlyStats();
    setState(() {});
  }

  bool _isAlternateSaturday(DateTime date) {
    if (date.weekday != DateTime.saturday) return false;
    final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
    return weekOfMonth == 2 || weekOfMonth == 4;
  }

  void _fetchAttendanceForSelectedMonth(BuildContext context) {
    final now = DateTime.now();
    final DateTime startDate =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);

    final DateTime endDate =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final DateTime finalEndDate =
        (_selectedMonth.year == now.year && _selectedMonth.month == now.month)
            ? now
            : endDate;

    final String fromDate = DateFormat('yyyy-MM-dd').format(startDate);

    final String toDate = DateFormat('yyyy-MM-dd').format(finalEndDate);

    context.read<TimeSheetBloc>().add(
          FetchEmpMonthAttendance(
            fromDate: toDate,
            toDate: fromDate,
            employeeId: widget.employee.id,
          ),
        );
  }

  void _calculateMonthlyStats() {
    _presentDays = 0;
    _absentDays = 0;
    _halfDays = 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    _attendanceMap.forEach((date, records) {
      final isToday = _fmt(todayDate) == date;
      final total = _totalWork(records, isToday: isToday);

      if (total.inHours >= 8) {
        _presentDays++;
      } else if (total.inHours >= 4) {
        _halfDays++;
      } else {
        _absentDays++;
      }
    });
  }

  // ================= WORK TIME =================
  Duration _totalWork(List<Attendance> records, {bool isToday = false}) {
    Duration total = Duration.zero;
    DateTime? lastIn;

    for (final r in records) {
      final time = DateTime.fromMillisecondsSinceEpoch(r.timeStamp);

      if (r.status) {
        lastIn = time; // check-in
      } else if (lastIn != null) {
        total += time.difference(lastIn); // check-out
        lastIn = null;
      }
    }

    // ✅ FIX: today ongoing check-in
    if (isToday && lastIn != null) {
      total += DateTime.now().difference(lastIn);
    }

    return total;
  }

  Color _dayColor(List<Attendance> records, {bool isToday = false}) {
    final work = _totalWork(records, isToday: isToday);

    // ✅ FIX: Today + checked-in at least once = PRESENT
    if (isToday && _hasCheckedIn(records)) {
      return Colors.green.withOpacity(0.3);
    }

    if (work.inHours >= 8) return Colors.green.withOpacity(0.3);
    if (work.inHours >= 4) return Colors.orange.withOpacity(0.3);

    return Colors.redAccent.withOpacity(0.3);
  }

  bool _hasCheckedIn(List<Attendance> records) {
    for (final r in records) {
      if (r.status) return true;
    }
    return false;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return BlocListener<TimeSheetBloc, TimeSheetState>(
      listener: (context, state) {
        if (state is AttendanceLoaded) {
          _mapApiToCalendar(state.data);
        }
        if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    final firstWeekdayIndex =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: widget.employee.name),
      body: Column(
        children: [
          _summaryCard(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _calendarHeader(),
                  _weekdayHeader(),
                  _calendarGrid(daysInMonth, firstWeekdayIndex),
                  _attendanceLegend(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= GRID =================
  Widget _calendarGrid(int daysInMonth, int firstWeekdayIndex) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42,
      itemBuilder: (_, index) {
        final day = index - firstWeekdayIndex + 1;
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
        final isToday = date == todayDate;
        final isFuture = date.isAfter(todayDate);

        final isSunday = date.weekday == DateTime.sunday;
        final isAltSaturday = _isAlternateSaturday(date);

        final isWeekend = isSunday || isAltSaturday;

        final key = _fmt(date);
        final records = _attendanceMap[key];

        Color bgColor;

        if (isWeekend) {
          bgColor = Colors.grey.withOpacity(0.3);
        } else if (isFuture) {
          bgColor = AppColors.card;
        } else if (records == null || records.isEmpty) {
          bgColor = Colors.red.withOpacity(0.3);
        } else {
          bgColor = _dayColor(records, isToday: isToday);
        }

        return GestureDetector(
          onTap: (records == null || isFuture || isWeekend)
              ? null
              : () => showDayDetails(date, records, context),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: isToday
                  ? Border.all(color: Colors.blue, width: 2)
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              '$day',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // ================= SUMMARY & LEGEND =================
  Widget _summaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Present', _presentDays, Colors.green),
          _stat('Absent', _absentDays, Colors.red),
          _stat('Half', _halfDays, Colors.amber),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _calendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth =
                    DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              _fetchAttendanceForSelectedMonth(context);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              final nextMonth =
                  DateTime(_selectedMonth.year, _selectedMonth.month + 1);

              final now = DateTime.now();

              // ❌ Block future months
              if (nextMonth.year > now.year ||
                  (nextMonth.year == now.year && nextMonth.month > now.month)) {
                return;
              }

              setState(() {
                _selectedMonth = nextMonth;
              });

              _fetchAttendanceForSelectedMonth(context);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m - 1];

  Widget _weekdayHeader() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: d == 'S' ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _attendanceLegend() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('Full Day', Colors.green),
          _legendItem('Half Day', Colors.orange),
          _legendItem('Absent', Colors.red),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
