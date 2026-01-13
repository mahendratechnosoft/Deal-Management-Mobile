class TaskLogModel {
  String taskLogId;
  String taskId;
  String adminId;
  dynamic employeeId;
  String name;
  DateTime startTime;
  dynamic endTime;
  dynamic endNote;
  dynamic durationInMinutes;
  String status;

  TaskLogModel({
    required this.taskLogId,
    required this.taskId,
    required this.adminId,
    required this.employeeId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.endNote,
    required this.durationInMinutes,
    required this.status,
  });

  factory TaskLogModel.fromJson(Map<String, dynamic> json) => TaskLogModel(
        taskLogId: json["taskLogId"],
        taskId: json["taskId"],
        adminId: json["adminId"],
        employeeId: json["employeeId"],
        name: json["name"],
        startTime: DateTime.parse(json["startTime"]),
        endTime: json["endTime"],
        endNote: json["endNote"],
        durationInMinutes: json["durationInMinutes"],
        status: json["status"],
      );
}
