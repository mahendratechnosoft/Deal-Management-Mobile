// To parse this JSON data, do
//
//     final taskUpdateRequest = taskUpdateRequestFromJson(jsonString);

import 'dart:convert';

TaskUpdateRequest taskUpdateRequestFromJson(String str) =>
    TaskUpdateRequest.fromJson(json.decode(str));

String taskUpdateRequestToJson(TaskUpdateRequest data) =>
    json.encode(data.toJson());

class TaskUpdateRequest {
  String taskId;
  String adminId;
  String employeeId;
  String subject;
  String startDate;
  dynamic endDate;
  String priority;
  String relatedTo;
  String relatedToId;
  String relatedToName;
  double hourlyRate;
  double estimatedHours;
  String description;
  String status;
  List<Employee> assignedEmployees;
  List<Employee> followersEmployees;
  DateTime createdAt;
  String createdBy;

  TaskUpdateRequest({
    required this.taskId,
    required this.adminId,
    required this.employeeId,
    required this.subject,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.relatedTo,
    required this.relatedToId,
    required this.relatedToName,
    required this.hourlyRate,
    required this.estimatedHours,
    required this.description,
    required this.status,
    required this.assignedEmployees,
    required this.followersEmployees,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaskUpdateRequest.fromJson(Map<String, dynamic> json) =>
      TaskUpdateRequest(
        taskId: json["taskId"],
        adminId: json["adminId"],
        employeeId: json["employeeId"],
        subject: json["subject"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        priority: json["priority"],
        relatedTo: json["relatedTo"],
        relatedToId: json["relatedToId"],
        relatedToName: json["relatedToName"],
        hourlyRate: json["hourlyRate"],
        estimatedHours: json["estimatedHours"],
        description: json["description"],
        status: json["status"],
        assignedEmployees: List<Employee>.from(
            json["assignedEmployees"].map((x) => Employee.fromJson(x))),
        followersEmployees: List<Employee>.from(
            json["followersEmployees"].map((x) => Employee.fromJson(x))),
        createdAt: DateTime.parse(json["createdAt"]),
        createdBy: json["createdBy"],
      );

  Map<String, dynamic> toJson() => {
        "taskId": taskId,
        "adminId": adminId,
        "employeeId": employeeId,
        "subject": subject,
        "startDate": startDate,
        "endDate": endDate,
        "priority": priority,
        "relatedTo": relatedTo,
        "relatedToId": relatedToId,
        "relatedToName": relatedToName,
        "hourlyRate": hourlyRate,
        "estimatedHours": estimatedHours,
        "description": description,
        "status": status,
        "assignedEmployees":
            List<dynamic>.from(assignedEmployees.map((x) => x.toJson())),
        "followersEmployees":
            List<dynamic>.from(followersEmployees.map((x) => x.toJson())),
        "createdAt": createdAt.toIso8601String(),
        "createdBy": createdBy,
      };
}

class Employee {
  String employeeId;
  String name;

  Employee({
    required this.employeeId,
    required this.name,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        employeeId: json["employeeId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "name": name,
      };
}
