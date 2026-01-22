class CheckInStatusModel {
  final String attendanceId;
  final String adminId;
  final String employeeId;
  final String employeeName;
  final int timeStamp;
  final bool status;

  CheckInStatusModel({
    required this.attendanceId,
    required this.adminId,
    required this.employeeId,
    required this.employeeName,
    required this.timeStamp,
    required this.status,
  });

  factory CheckInStatusModel.fromJson(Map<String, dynamic> json) {
    return CheckInStatusModel(
      attendanceId: json['attendanceId'] ?? '',
      adminId: json['adminId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      timeStamp: json['timeStamp'] ?? 0,
      status: json['status'] ?? false,
    );
  }
}

class DateAttendance {
  final String date;
  final List<CheckInStatusModel> records;

  DateAttendance({required this.date, required this.records});
}

class EmployeeAttendanceResponse {
  final String employeeName;
  final List<DateAttendance> dates;

  EmployeeAttendanceResponse({
    required this.employeeName,
    required this.dates,
  });

  factory EmployeeAttendanceResponse.fromJson(Map<String, dynamic> json) {
    final employeeName = json.keys.first;
    final Map<String, dynamic> dateMap = json[employeeName];

    final dates = <DateAttendance>[];

    dateMap.forEach((date, list) {
      final records =
          (list as List).map((e) => CheckInStatusModel.fromJson(e)).toList();

      dates.add(DateAttendance(date: date, records: records));
    });

    return EmployeeAttendanceResponse(
      employeeName: employeeName,
      dates: dates,
    );
  }
}
