class EmpMonthAttendanceModel {
  final Map<String, Map<String, List<Attendance>>> data;

  EmpMonthAttendanceModel({required this.data});

  factory EmpMonthAttendanceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, Map<String, List<Attendance>>> result = {};

    json.forEach((employeeName, employeeData) {
      if (employeeData is Map<String, dynamic>) {
        final Map<String, List<Attendance>> dateMap = {};

        employeeData.forEach((date, records) {
          if (records is List) {
            dateMap[date] =
                records.map((e) => Attendance.fromJson(e)).toList();
          }
        });

        if (dateMap.isNotEmpty) {
          result[employeeName] = dateMap;
        }
      }
    });

    return EmpMonthAttendanceModel(data: result);
  }
}

class Attendance {
  final String attendanceId;
  final String adminId;
  final String employeeId;
  final String employeeName;
  final int timeStamp;
  final bool status;

  Attendance({
    required this.attendanceId,
    required this.adminId,
    required this.employeeId,
    required this.employeeName,
    required this.timeStamp,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendanceId'],
      adminId: json['adminId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      timeStamp: json['timeStamp'],
      status: json['status'],
    );
  }
}
