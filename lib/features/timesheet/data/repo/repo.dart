import 'package:dio/dio.dart';
import 'package:xpertbiz/features/timesheet/data/model/calendar_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/checkIn_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/employee_item_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/get_all_emp_status.dart';
import 'package:xpertbiz/features/timesheet/data/service/service.dart';
import '../model/checkIn_status_model.dart';

class TimeSheetRepository {
  final TimesheetService apiService;

  TimeSheetRepository(this.apiService);

  Future<List<GetAllEmpStatusModel>> getAllEmpStatus(String date) async {
    final response = await apiService.getAllEmpStatus(date);
    if (response.data is! List) return [];
    return (response.data as List)
        .map((e) => GetAllEmpStatusModel.fromJson(e))
        .toList();
  }

  Future<List<CalendarModel>> getCalendar({
    required String startDate,
    required String endDate,
  }) async {
    final response = await apiService.getCalendar(
      startDate: startDate,
      endDate: endDate,
    );
    if (response.data is! List) return [];
    return (response.data as List)
        .map((e) => CalendarModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EmployeeItemModel>> getEmployeeNameAndId({
    bool excludeMe = false,
  }) async {
    final response = await apiService.getEmployeeNameAndId(excludeMe: excludeMe);
    if (response.data is! List) return [];
    return (response.data as List)
        .map((e) => EmployeeItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EmpMonthAttendanceModel> empMonthAttendance({
    required String fromDate,
    required String toDate,
    String? employeeId,
  }) async {
    final response = await apiService.empMonthAttendance(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );

    if (response.data is Map<String, dynamic>) {
      return EmpMonthAttendanceModel.fromJson(response.data as Map<String, dynamic>);
    }
    return EmpMonthAttendanceModel(data: {});
  }

  Future<CheckInModel> checkIn(bool checkIn) async {
    final response = await apiService.checkIn(checkIn);
    return CheckInModel.fromJson(
      response.data is Map<String, dynamic> ? response.data : {},
    );
  }

  Future<EmployeeAttendanceResponse> checkInStatus({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    final response = await apiService.checkInStatus(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );

    if (response.data is Map<String, dynamic>) {
      return EmployeeAttendanceResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    return EmployeeAttendanceResponse(employeeName: '', dates: []);
  }

  Future<Response> updateAttendance({
    required String employeeId,
    required bool status,
    required int timeStamp,
    String? attendanceId,
  }) {
    return apiService.updateAttendance(
      employeeId: employeeId,
      status: status,
      timeStamp: timeStamp,
      attendanceId: attendanceId,
    );
  }

  Future<Response> deleteAttendance(String attendanceId) {
    return apiService.deleteAttendance(attendanceId);
  }

  Future<void> deleteAttendanceSession(List<String> attendanceIds) async {
    for (final id in attendanceIds) {
      if (id.isNotEmpty) {
        await apiService.deleteAttendance(id);
      }
    }
  }
}
