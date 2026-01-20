import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_error.dart';
import '../data/repo/repo.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';

class TimeSheetBloc extends Bloc<TimeSheetEvent, TimeSheetState> {
  final TimeSheetRepository repository;

  TimeSheetBloc(this.repository) : super(TimeSheetInitial()) {
    on<FetchAllEmpStatus>(_onFetchAllEmpStatus);
    on<FetchEmpMonthAttendance>(_onFetchEmpMonthAttendance);
    on<ResetToEmployeeList>(_onResetToEmployeeList);
  }

  Future<void> _onResetToEmployeeList(
    ResetToEmployeeList event,
    Emitter<TimeSheetState> emit,
  ) async {
    emit(TimeSheetInitial());
    await _onFetchAllEmpStatus(
      FetchAllEmpStatus(event.date),
      emit,
    );
  }

  Future<void> _onFetchAllEmpStatus(
    FetchAllEmpStatus event,
    Emitter<TimeSheetState> emit,
  ) async {
    emit(TimeSheetLoading());

    try {
      final employees = await repository.getAllEmpStatus(event.date);

      if (employees.isEmpty) {
        emit(TimeSheetEmpty());
      } else {
        emit(TimeSheetLoaded(employees));
      }
    } on DioException catch (dioError) {
      final message = ApiError.getMessage(dioError);
      emit(TimeSheetError(message));
    } catch (error) {
      emit(const TimeSheetError(
        'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onFetchEmpMonthAttendance(
    FetchEmpMonthAttendance event,
    Emitter<TimeSheetState> emit,
  ) async {
    try {
      final data = await repository.empMonthAttendance(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(AttendanceLoaded(data));
    } on DioException catch (dioError) {
      final message = ApiError.getMessage(dioError);

      ApiError.getMessage(dioError);
      emit(AttendanceError(
        message: message,
      ));
    } catch (error) {
      emit(
        AttendanceError(
          message: 'Failed to load attendance',
        ),
      );
    }
  }
}
