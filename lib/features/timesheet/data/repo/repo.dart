import 'package:xpertbiz/features/timesheet/data/model/checkIn_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/get_all_emp_status.dart';
import 'package:xpertbiz/features/timesheet/data/service/service.dart';

import '../model/checkIn_status_model.dart';

class TimeSheetRepository {
  final TimesheetService apiService;

  TimeSheetRepository(this.apiService);

  Future<List<GetAllEmpStatusModel>> getAllEmpStatus(String date) async {
    final response = await apiService.getAllEmpStatus(date);
    return (response.data as List)
        .map((e) => GetAllEmpStatusModel.fromJson(e))
        .toList();
  }

  Future<EmpMonthAttendanceModel> empMonthAttendance(
      {required String fromDate,
      required String toDate,
      required String employeeId}) async {
    final response = await apiService.empMonthAttendance(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );

    return EmpMonthAttendanceModel.fromJson(response.data);
  }

  Future<CheckInModel> checkIn(bool checkIn) async {
    final response = await apiService.checkIn(checkIn);
    return CheckInModel.fromJson(response.data);
  }

  //
  Future<EmployeeAttendanceResponse> checkInStatus({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    final response = await apiService.empMonthAttendance(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );

    return EmployeeAttendanceResponse.fromJson(response.data);
  }
}
