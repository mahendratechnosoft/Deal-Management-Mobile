import 'package:equatable/equatable.dart';
import '../data/model/calendar_model.dart';
import '../data/model/checkIn_status_model.dart';
import '../data/model/emp_month_attendance_model.dart';
import '../data/model/employee_item_model.dart';
import '../data/model/get_all_emp_status.dart';

abstract class TimeSheetState extends Equatable {
  const TimeSheetState();

  @override
  List<Object?> get props => [];
}

class TimeSheetInitial extends TimeSheetState {}

class TimeSheetLoading extends TimeSheetState {}

class TimeSheetEmpty extends TimeSheetState {}

class TimeSheetError extends TimeSheetState {
  final String message;
  const TimeSheetError(this.message);

  @override
  List<Object?> get props => [message];
}

class TimeSheetLoaded extends TimeSheetState {
  /// Employee list for legacy/status list
  final List<GetAllEmpStatusModel> employees;
  final List<GetAllEmpStatusModel> allEmployees;

  /// Check-in runtime data
  final bool isCheckedIn;
  final int? startTimestamp;

  /// Monthly attendance
  final EmpMonthAttendanceModel? monthlyAttendance;

  /// Today check-in status
  final EmployeeAttendanceResponse? checkInStatus;

  /// 📅 Monthly Timesheet Grid specific data
  final DateTime? selectedMonth;
  final List<EmployeeItemModel> employeeList;
  final List<EmployeeItemModel> filteredEmployeeList;
  final Map<String, CalendarModel> calendarMap;
  final bool isGridLoading;

  const TimeSheetLoaded({
    this.employees = const [],
    this.allEmployees = const [],
    this.isCheckedIn = false,
    this.startTimestamp,
    this.monthlyAttendance,
    this.checkInStatus,
    this.selectedMonth,
    this.employeeList = const [],
    this.filteredEmployeeList = const [],
    this.calendarMap = const {},
    this.isGridLoading = false,
  });

  TimeSheetLoaded copyWith({
    List<GetAllEmpStatusModel>? employees,
    List<GetAllEmpStatusModel>? allEmployees,
    bool? isCheckedIn,
    int? startTimestamp,
    EmpMonthAttendanceModel? monthlyAttendance,
    EmployeeAttendanceResponse? checkInStatus,
    DateTime? selectedMonth,
    List<EmployeeItemModel>? employeeList,
    List<EmployeeItemModel>? filteredEmployeeList,
    Map<String, CalendarModel>? calendarMap,
    bool? isGridLoading,
  }) {
    return TimeSheetLoaded(
      employees: employees ?? this.employees,
      allEmployees: allEmployees ?? this.allEmployees,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      monthlyAttendance: monthlyAttendance ?? this.monthlyAttendance,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      employeeList: employeeList ?? this.employeeList,
      filteredEmployeeList: filteredEmployeeList ?? this.filteredEmployeeList,
      calendarMap: calendarMap ?? this.calendarMap,
      isGridLoading: isGridLoading ?? this.isGridLoading,
    );
  }

  @override
  List<Object?> get props => [
        employees,
        allEmployees,
        isCheckedIn,
        startTimestamp,
        monthlyAttendance,
        checkInStatus,
        selectedMonth,
        employeeList,
        filteredEmployeeList,
        calendarMap,
        isGridLoading,
      ];
}
