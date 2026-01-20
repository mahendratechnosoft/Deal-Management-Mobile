import 'package:equatable/equatable.dart';
import '../data/model/emp_month_attendance_model.dart';
import '../data/model/get_all_emp_status.dart';

abstract class TimeSheetState extends Equatable {
  const TimeSheetState();

  @override
  List<Object?> get props => [];
}

class TimeSheetInitial extends TimeSheetState {}

class TimeSheetLoading extends TimeSheetState {}

class TimeSheetLoaded extends TimeSheetState {
  final List<GetAllEmpStatusModel> employees;

  const TimeSheetLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

class TimeSheetEmpty extends TimeSheetState {}

class TimeSheetError extends TimeSheetState {
  final String message;

  const TimeSheetError(this.message);

  @override
  List<Object?> get props => [message];
}

/// ================= ATTENDANCE STATES =================

class AttendanceInitial extends TimeSheetState {}

class AttendanceLoading extends TimeSheetState {
  final EmpMonthAttendanceModel? previousData;

  const AttendanceLoading({this.previousData});

  AttendanceLoading copyWith({
    EmpMonthAttendanceModel? previousData,
  }) {
    return AttendanceLoading(
      previousData: previousData ?? this.previousData,
    );
  }

  @override
  List<Object?> get props => [previousData];
}

class AttendanceLoaded extends TimeSheetState {
  final EmpMonthAttendanceModel data;

  const AttendanceLoaded(this.data);

  AttendanceLoaded copyWith({
    EmpMonthAttendanceModel? data,
  }) {
    return AttendanceLoaded(data ?? this.data);
  }

  @override
  List<Object?> get props => [data];
}

class AttendanceError extends TimeSheetState {
  final String message;
  final EmpMonthAttendanceModel? previousData;

  const AttendanceError({
    required this.message,
    this.previousData,
  });

  AttendanceError copyWith({
    String? message,
    EmpMonthAttendanceModel? previousData,
  }) {
    return AttendanceError(
      message: message ?? this.message,
      previousData: previousData ?? this.previousData,
    );
  }

  @override
  List<Object?> get props => [message, previousData];
}
