class CheckTimerStatusModel {
  final String taskLogId;
  final String taskId;
  final String adminId;
  final String? employeeId;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final String? endNote;
  final int? durationInMinutes;
  final String status;

  CheckTimerStatusModel({
    required this.taskLogId,
    required this.taskId,
    required this.adminId,
    this.employeeId,
    required this.name,
    required this.startTime,
    this.endTime,
    this.endNote,
    this.durationInMinutes,
    required this.status,
  });

  factory CheckTimerStatusModel.fromJson(Map<String, dynamic> json) {
    return CheckTimerStatusModel(
      taskLogId: json['taskLogId'] ?? '',
      taskId: json['taskId'] ?? '',
      adminId: json['adminId'] ?? '',
      employeeId: json['employeeId'],
      name: json['name'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      endNote: json['endNote'],
      durationInMinutes: json['durationInMinutes'],
      status: json['status'] ?? '',
    );
  }
}
