import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/features/auth/bloc/user_role.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import '../../../core/network/api_error.dart';
import '../data/model/calendar_model.dart';
import '../data/model/emp_month_attendance_model.dart';
import '../data/model/employee_item_model.dart';
import '../data/model/get_all_emp_status.dart';
import '../data/repo/repo.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';

class TimeSheetBloc extends Bloc<TimeSheetEvent, TimeSheetState> {
  final TimeSheetRepository repository;

  TimeSheetBloc(this.repository) : super(TimeSheetInitial()) {
    on<FetchMonthlyTimesheetGrid>(_onFetchMonthlyTimesheetGrid);
    on<FilterTimesheetEmployees>(_onFilterTimesheetEmployees);
    on<FetchAllEmpStatus>(_onFetchAllEmpStatus);
    on<FetchEmpMonthAttendance>(_onFetchEmpMonthAttendance);
    on<ResetToEmployeeList>(_onResetToEmployeeList);
    on<FilterEmployees>(_onFilterEmployees);
    on<CheckStatusEvent>(_onCheckIn);
  }

  /// 📅 Fetch Full Monthly Timesheet Grid data (Calendar + Employees + Month Attendance)
  Future<void> _onFetchMonthlyTimesheetGrid(
    FetchMonthlyTimesheetGrid event,
    Emitter<TimeSheetState> emit,
  ) async {
    final DateTime month = event.month;
    final String startDate =
        "${month.year}-${month.month.toString().padLeft(2, '0')}-01";
    final int lastDayInt = DateTime(month.year, month.month + 1, 0).day;
    final String endDate =
        "${month.year}-${month.month.toString().padLeft(2, '0')}-${lastDayInt.toString().padLeft(2, '0')}";

    if (state is TimeSheetLoaded) {
      emit((state as TimeSheetLoaded).copyWith(
        selectedMonth: month,
        isGridLoading: true,
      ));
    } else {
      emit(TimeSheetLoading());
    }

    try {
      final user = AuthLocalStorage.getUser();
      final bool canViewAll = user?.moduleAccess.timeSheetViewAll ?? false;

      // 1. Fetch Calendar off-days/holidays
      final calendarFuture = repository.getCalendar(
        startDate: startDate,
        endDate: endDate,
      );

      // 2. Fetch Employee list (names and IDs)
      final employeeFuture = repository.getEmployeeNameAndId(
        excludeMe: false,
      );

      // 3. Fetch Monthly Attendance (all employees if canViewAll, else current employee only)
      final attendanceFuture = repository.empMonthAttendance(
        fromDate: startDate,
        toDate: endDate,
        employeeId: canViewAll ? null : user?.employeeId,
      );

      final results = await Future.wait([
        calendarFuture,
        employeeFuture,
        attendanceFuture,
      ]);

      final calendarList = results[0] as List<CalendarModel>;
      final employeeList = results[1] as List<EmployeeItemModel>;
      final attendance = results[2] as EmpMonthAttendanceModel;

      final Map<String, CalendarModel> calendarMap = {
        for (final item in calendarList) item.date: item,
      };

      // Apply module access permission: timeSheetViewAll
      List<EmployeeItemModel> visibleEmployees = employeeList;
      if (!canViewAll) {
        final myId = user?.employeeId;
        final myName = user?.loginUserName;

        visibleEmployees = employeeList.where((e) {
          if (myId != null && myId.isNotEmpty && e.employeeId == myId) {
            return true;
          }
          if (myName != null &&
              myName.isNotEmpty &&
              e.name.toLowerCase() == myName.toLowerCase()) {
            return true;
          }
          return false;
        }).toList();

        // If employee list from server didn't contain user, synthesize user's row
        if (visibleEmployees.isEmpty && myId != null) {
          visibleEmployees = [
            EmployeeItemModel(
              employeeId: myId,
              name: myName ?? 'My Timesheet',
            ),
          ];
        }
      }

      if (state is TimeSheetLoaded) {
        emit(
          (state as TimeSheetLoaded).copyWith(
            selectedMonth: month,
            employeeList: visibleEmployees,
            filteredEmployeeList: visibleEmployees,
            calendarMap: calendarMap,
            monthlyAttendance: attendance,
            isGridLoading: false,
          ),
        );
      } else {
        emit(
          TimeSheetLoaded(
            selectedMonth: month,
            employeeList: visibleEmployees,
            filteredEmployeeList: visibleEmployees,
            calendarMap: calendarMap,
            monthlyAttendance: attendance,
            isGridLoading: false,
          ),
        );
      }
    } on DioException catch (e) {
      emit(TimeSheetError(ApiError.getMessage(e)));
    } catch (e) {
      emit(TimeSheetError('Failed to load timesheet: $e'));
    }
  }

  /// 🔍 Filter employees in Timesheet Grid
  void _onFilterTimesheetEmployees(
    FilterTimesheetEmployees event,
    Emitter<TimeSheetState> emit,
  ) {
    if (state is! TimeSheetLoaded) return;
    final current = state as TimeSheetLoaded;
    final q = event.query.toLowerCase().trim();

    if (q.isEmpty) {
      emit(current.copyWith(filteredEmployeeList: current.employeeList));
      return;
    }

    final filtered = current.employeeList.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.employeeId.toLowerCase().contains(q);
    }).toList();

    emit(current.copyWith(filteredEmployeeList: filtered));
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
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final employees = await repository.getAllEmpStatus(event.date);
      if (employees.isEmpty) {
        emit(TimeSheetEmpty());
        return;
      }

      final user = AuthLocalStorage.getUser();
      final bool canViewAll = user?.moduleAccess.timeSheetViewAll ?? false;

      List<GetAllEmpStatusModel> visibleEmployees = employees;
      if (!canViewAll && user?.employeeId != null) {
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

  /// 🔍 Filter employees locally (legacy)
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

  /// 📊 Monthly attendance for single employee
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

      emit(
        (state as TimeSheetLoaded).copyWith(
          monthlyAttendance: data,
        ),
      );
    } catch (_) {
      emit(const TimeSheetError('Attendance load failed'));
    }
  }

  Future<void> _onCheckIn(
    CheckStatusEvent event,
    Emitter<TimeSheetState> emit,
  ) async {
    try {
      final res = await repository.checkIn(event.checkIn);

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
}
