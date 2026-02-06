import 'package:equatable/equatable.dart';
import '../data/model/checkIn_status_model.dart';
import '../data/model/emp_month_attendance_model.dart';
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

/// 🔥 SINGLE SOURCE OF TRUTH STATE
/// All screen-related data lives here
class TimeSheetLoaded extends TimeSheetState {
  /// Employee list
  final List<GetAllEmpStatusModel> employees;
  final List<GetAllEmpStatusModel> allEmployees;

  /// Check-in runtime data
  final bool isCheckedIn;
  final int? startTimestamp;

  /// Monthly attendance
  final EmpMonthAttendanceModel? monthlyAttendance;

  /// Today check-in status
  final EmployeeAttendanceResponse? checkInStatus;

  

  const TimeSheetLoaded({
    required this.employees,
    required this.allEmployees,
    this.isCheckedIn = false,
    this.startTimestamp,
    this.monthlyAttendance,
    this.checkInStatus,

  });

  TimeSheetLoaded copyWith({
    List<GetAllEmpStatusModel>? employees,
    List<GetAllEmpStatusModel>? allEmployees,
    bool? isCheckedIn,
    int? startTimestamp,
    EmpMonthAttendanceModel? monthlyAttendance,
    EmployeeAttendanceResponse? checkInStatus,
  }) {
    return TimeSheetLoaded(
      employees: employees ?? this.employees,
      allEmployees: allEmployees ?? this.allEmployees,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      monthlyAttendance: monthlyAttendance ?? this.monthlyAttendance,
      checkInStatus: checkInStatus ?? this.checkInStatus,
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
      ];
}



