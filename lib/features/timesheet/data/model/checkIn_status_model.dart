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
      attendanceId: json['attendanceId']?.toString() ?? '',
      adminId: json['adminId']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      timeStamp: json['timeStamp'] is int ? json['timeStamp'] : 0,
      status: json['status'] == true,
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
    if (json.isEmpty) {
      return EmployeeAttendanceResponse(employeeName: '', dates: []);
    }
    final employeeName = json.keys.first;
    final dynamic rawDateMap = json[employeeName];
    if (rawDateMap is! Map<String, dynamic>) {
      return EmployeeAttendanceResponse(employeeName: employeeName, dates: []);
    }

    final dates = <DateAttendance>[];

    rawDateMap.forEach((date, list) {
      if (list is List) {
        final records =
            list.map((e) => CheckInStatusModel.fromJson(e)).toList();

        dates.add(DateAttendance(date: date, records: records));
      }
    });

    return EmployeeAttendanceResponse(
      employeeName: employeeName,
      dates: dates,
    );
  }
}
