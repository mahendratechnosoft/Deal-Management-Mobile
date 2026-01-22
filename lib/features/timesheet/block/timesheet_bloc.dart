import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import '../../../core/network/api_error.dart';
import '../data/model/get_all_emp_status.dart';
import '../data/repo/repo.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';

class TimeSheetBloc extends Bloc<TimeSheetEvent, TimeSheetState> {
  final TimeSheetRepository repository;

  TimeSheetBloc(this.repository) : super(TimeSheetInitial()) {
    on<FetchAllEmpStatus>(_onFetchAllEmpStatus);
    on<FetchEmpMonthAttendance>(_onFetchEmpMonthAttendance);
    on<ResetToEmployeeList>(_onResetToEmployeeList);
    on<FilterEmployees>(_onFilterEmployees);
    on<CheckInEvent>(_onCheckIn);
    on<CheckInStatusEvent>(_onCheckInStatus);
  }

  /// 🔁 Reset and reload employee list
  Future<void> _onResetToEmployeeList(
    ResetToEmployeeList event,
    Emitter<TimeSheetState> emit,
  ) async {
    emit(TimeSheetInitial());
    await _onFetchAllEmpStatus(FetchAllEmpStatus(event.date), emit);
  }

  /// 👥 Load employees based on role
  Future<void> _onFetchAllEmpStatus(
    FetchAllEmpStatus event,
    Emitter<TimeSheetState> emit,
  ) async {
    emit(TimeSheetLoading());

    try {
      final employees = await repository.getAllEmpStatus(event.date);
      if (employees.isEmpty) {
        emit(TimeSheetEmpty());
        return;
      }

      final role = RoleResolver.rolePath;
      final user = AuthLocalStorage.getUser();

      List<GetAllEmpStatusModel> visibleEmployees = employees;

      /// Employee sees only himself
      if (role == 'employee' && user?.employeeId != null) {
        visibleEmployees =
            employees.where((e) => e.employeeId == user!.employeeId).toList();
      }

      emit(
        TimeSheetLoaded(
          employees: visibleEmployees,
          allEmployees: visibleEmployees,
        ),
      );
    } on DioException catch (e) {
      emit(TimeSheetError(ApiError.getMessage(e)));
    }
  }

  /// 🔍 Filter employees locally
  void _onFilterEmployees(
    FilterEmployees event,
    Emitter<TimeSheetState> emit,
  ) {
    if (state is! TimeSheetLoaded) return;

    final current = state as TimeSheetLoaded;
    final q = event.query.toLowerCase().trim();

    if (q.isEmpty) {
      emit(current.copyWith(employees: current.allEmployees));
      return;
    }

    final filtered = current.allEmployees.where((e) {
      return e.employeeName.toLowerCase().contains(q) ||
          e.employeeId.toLowerCase().contains(q);
    }).toList();

    emit(current.copyWith(employees: filtered));
  }

  /// 📊 Monthly attendance
  Future<void> _onFetchEmpMonthAttendance(
    FetchEmpMonthAttendance event,
    Emitter<TimeSheetState> emit,
  ) async {
    if (state is! TimeSheetLoaded) return;

    try {
      final data = await repository.empMonthAttendance(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      log('Attendance fetched: ${data.data.length}');

      emit(
        (state as TimeSheetLoaded).copyWith(
          monthlyAttendance: data,
        ),
      );
    } catch (_) {
      emit(const TimeSheetError('Attendance load failed'));
    }
  }

  /// ⏱ Check-in / Check-out
  Future<void> _onCheckIn(
    CheckInEvent event,
    Emitter<TimeSheetState> emit,
  ) async {
    try {
      final res = await repository.checkIn(event.checkIn);

      log('Check-in response: ${res.status}, ${res.timeStamp}');

      if (state is TimeSheetLoaded) {
        emit(
          (state as TimeSheetLoaded).copyWith(
            isCheckedIn: res.status,
            startTimestamp: res.timeStamp,
          ),
        );
      }
    } on DioException catch (e) {
      emit(TimeSheetError(ApiError.getMessage(e)));
    }
  }

  /// 🟢 Get today check-in status
  Future<void> _onCheckInStatus(
    CheckInStatusEvent event,
    Emitter<TimeSheetState> emit,
  ) async {
    if (state is! TimeSheetLoaded) return;

    try {
      final result = await repository.checkInStatus(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      final lastRecord = result.dates.first.records.last;

      log('Check-in status fetched: ${lastRecord.status}');

      emit(
        (state as TimeSheetLoaded).copyWith(
          checkInStatus: result,
          isCheckedIn: lastRecord.status,
          startTimestamp: lastRecord.timeStamp,
        ),
      );
    } catch (_) {
      emit(const TimeSheetError('Check-in status load failed'));
    }
  }
}
