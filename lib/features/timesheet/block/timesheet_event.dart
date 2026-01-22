import 'package:equatable/equatable.dart';

abstract class TimeSheetEvent extends Equatable {
  const TimeSheetEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all employee status by date
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

// In timesheet_event.dart
class ResetToEmployeeList extends TimeSheetEvent {
  final String date;

  const ResetToEmployeeList(this.date);

  @override
  List<Object?> get props => [date];
}

class FilterEmployees extends TimeSheetEvent {
  final String query;
  const FilterEmployees(this.query);
}

class CheckInEvent extends TimeSheetEvent {
  final bool checkIn;
  const CheckInEvent(this.checkIn);
}

class CheckInStatusEvent extends TimeSheetEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const CheckInStatusEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, employeeId];
}
