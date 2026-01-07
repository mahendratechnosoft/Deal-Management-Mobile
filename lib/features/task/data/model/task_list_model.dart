// To parse this JSON data, do
//
//     final taskListModel = taskListModelFromJson(jsonString);

import 'dart:convert';

TaskListModel taskListModelFromJson(String str) =>
    TaskListModel.fromJson(json.decode(str));

String taskListModelToJson(TaskListModel data) => json.encode(data.toJson());

class TaskListModel {
  int totalElement;
  int totalPages;
  List<TaskList> taskList;
  int currentPage;

  TaskListModel({
    required this.totalElement,
    required this.totalPages,
    required this.taskList,
    required this.currentPage,
  });

  factory TaskListModel.fromJson(Map<String, dynamic> json) => TaskListModel(
        totalElement: json["totalElement"],
        totalPages: json["totalPages"],
        taskList: List<TaskList>.from(
            json["taskList"].map((x) => TaskList.fromJson(x))),
        currentPage: json["currentPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalElement": totalElement,
        "totalPages": totalPages,
        "taskList": List<dynamic>.from(taskList.map((x) => x.toJson())),
        "currentPage": currentPage,
      };
}

class TaskList {
  String taskId;
  String adminId;
  dynamic employeeId;
  String subject;
  DateTime startDate;
  DateTime endDate;
  String priority;
  String? relatedTo;
  String? relatedToId;
  String relatedToName;
  double hourlyRate;
  double estimatedHours;
  String description;
  String status;
  List<AssignedEmployee> assignedEmployees;
  List<dynamic> followersEmployees;
  DateTime createdAt;
  String createdBy;

  TaskList({
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

  factory TaskList.fromJson(Map<String, dynamic> json) => TaskList(
        taskId: json["taskId"],
        adminId: json["adminId"],
        employeeId: json["employeeId"],
        subject: json["subject"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        priority: json["priority"],
        relatedTo: json["relatedTo"],
        relatedToId: json["relatedToId"],
        relatedToName: json["relatedToName"],
        hourlyRate: json["hourlyRate"],
        estimatedHours: json["estimatedHours"]?.toDouble(),
        description: json["description"],
        status: json["status"],
        assignedEmployees: List<AssignedEmployee>.from(
            json["assignedEmployees"].map((x) => AssignedEmployee.fromJson(x))),
        followersEmployees:
            List<dynamic>.from(json["followersEmployees"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        createdBy: json["createdBy"],
      );

  Map<String, dynamic> toJson() => {
        "taskId": taskId,
        "adminId": adminId,
        "employeeId": employeeId,
        "subject": subject,
        "startDate":
            "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "endDate":
            "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
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
            List<dynamic>.from(followersEmployees.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "createdBy": createdBy,
      };
}

class AssignedEmployee {
  String employeeId;
  String name;

  AssignedEmployee({
    required this.employeeId,
    required this.name,
  });

  factory AssignedEmployee.fromJson(Map<String, dynamic> json) =>
      AssignedEmployee(
        employeeId: json["employeeId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "name": name,
      };
}
