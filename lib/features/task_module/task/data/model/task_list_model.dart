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

  factory TaskListModel.fromJson(Map<String, dynamic> json) {
    final listRaw = json["taskList"] ?? json["content"] ?? json["tasks"] ?? [];
    return TaskListModel(
      totalElement: (json["totalElement"] ?? json["totalElements"] ?? 0) is int
          ? (json["totalElement"] ?? json["totalElements"] ?? 0)
          : int.tryParse((json["totalElement"] ?? json["totalElements"] ?? 0).toString()) ?? 0,
      totalPages: (json["totalPages"] ?? 0) is int
          ? (json["totalPages"] ?? 0)
          : int.tryParse((json["totalPages"] ?? 0).toString()) ?? 0,
      taskList: listRaw is List
          ? listRaw
              .map((x) => TaskList.fromJson(x as Map<String, dynamic>))
              .toList()
          : [],
      currentPage: (json["currentPage"] ?? 0) is int
          ? (json["currentPage"] ?? 0)
          : int.tryParse((json["currentPage"] ?? 0).toString()) ?? 0,
    );
  }

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

  factory TaskList.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      return DateTime.tryParse(date.toString()) ?? DateTime.now();
    }

    final start = parseDate(json["startDate"]);
    final end = json["endDate"] != null ? parseDate(json["endDate"]) : start;
    final created = parseDate(json["createdAt"]);

    return TaskList(
      taskId: json["taskId"]?.toString() ?? "NA",
      adminId: json["adminId"]?.toString() ?? "NA",
      employeeId: json["employeeId"] ?? "NA",
      subject: json["subject"]?.toString() ?? "NA",
      startDate: start,
      endDate: end,
      priority: json["priority"]?.toString() ?? "NA",
      relatedTo: json["relatedTo"]?.toString() ?? "NA",
      relatedToId: json["relatedToId"]?.toString() ?? "NA",
      relatedToName: json["relatedToName"]?.toString() ?? "NA",
      hourlyRate: (json["hourlyRate"] as num?)?.toDouble() ?? 0.0,
      estimatedHours: (json["estimatedHours"] as num?)?.toDouble() ?? 0.0,
      description: json["description"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "NA",
      assignedEmployees: (json["assignedEmployees"] as List<dynamic>? ?? [])
          .map((x) => AssignedEmployee.fromJson(x as Map<String, dynamic>))
          .toList(),
      followersEmployees:
          List<dynamic>.from(json["followersEmployees"] as List<dynamic>? ?? []),
      createdAt: created,
      createdBy: json["createdBy"]?.toString() ?? "NA",
    );
  }

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
        employeeId: json["employeeId"]??'NA',
        name: json["name"]??"NA",
      );

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "name": name,
      };
}
