import 'package:xpertbiz/features/timesheet/data/model/emp_month_attendance_model.dart';
import 'package:xpertbiz/features/timesheet/data/model/get_all_emp_status.dart';
import 'package:xpertbiz/features/timesheet/data/service/service.dart';

class TimeSheetRepository {
  final TimesheetService apiService;

  TimeSheetRepository(this.apiService);

  Future<List<GetAllEmpStatusModel>> getAllEmpStatus(String date) async {
    final response = await apiService.getAllEmpStatus(date);
    return (response.data as List)
        .map((e) => GetAllEmpStatusModel.fromJson(e))
        .toList();
  }

  Future<EmpMonthAttendanceModel> empMonthAttendance({
    required String fromDate,
    required String toDate,
    required String employeeId,
  }) async {
    final response = await apiService.empMonthAttendance(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: employeeId,
    );

    return EmpMonthAttendanceModel.fromJson(response.data);
  }
}
