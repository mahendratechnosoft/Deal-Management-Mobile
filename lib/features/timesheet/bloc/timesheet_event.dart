import 'package:equatable/equatable.dart';

abstract class TimeSheetEvent extends Equatable {
  const TimeSheetEvent();

  @override
  List<Object?> get props => [];
}

/// 📅 Fetch Full Monthly Timesheet Grid (Employees + Calendar + Attendance)
class FetchMonthlyTimesheetGrid extends TimeSheetEvent {
  final DateTime month;
  const FetchMonthlyTimesheetGrid(this.month);

  @override
  List<Object?> get props => [month];
}

/// 👥 Fetch all employee status by date (for legacy list view)
class FetchAllEmpStatus extends TimeSheetEvent {
  final String date;
  const FetchAllEmpStatus(this.date);

  @override
  List<Object?> get props => [date];
}

class FetchEmpMonthAttendance extends TimeSheetEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const FetchEmpMonthAttendance({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, employeeId];
}

class ResetToEmployeeList extends TimeSheetEvent {
  final String date;

  const ResetToEmployeeList(this.date);

  @override
  List<Object?> get props => [date];
}

class FilterEmployees extends TimeSheetEvent {
  final String query;
  const FilterEmployees(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTimesheetEmployees extends TimeSheetEvent {
  final String query;
  const FilterTimesheetEmployees(this.query);

  @override
  List<Object?> get props => [query];
}

class CheckStatusEvent extends TimeSheetEvent {
  final bool checkIn;
  const CheckStatusEvent(this.checkIn);

  @override
  List<Object?> get props => [checkIn];
}
