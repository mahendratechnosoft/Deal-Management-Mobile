class GetTaskModel {
  final Task task;
  final bool canEdit;
  final bool canStartTimer;

  GetTaskModel({
    required this.task,
    required this.canEdit,
    required this.canStartTimer,
  });

  factory GetTaskModel.fromJson(Map<String, dynamic> json) {
    return GetTaskModel(
      task: Task.fromJson(json['task']),
      canEdit: json['canEdit'] ?? false,
      canStartTimer: json['canStartTimer'] ?? false,
    );
  }
}

class Task {
  final String taskId;
  final String adminId;
  final String? employeeId;
  final String subject;
  final DateTime startDate;
  final DateTime endDate;
  final String priority;
  final String relatedTo;
  final String relatedToId;
  final String relatedToName;
  final double hourlyRate;
  final double estimatedHours;
  final String description;
  final String status;
  final List<Employee> assignedEmployees;
  final List<Employee> followersEmployees;
  final DateTime createdAt;
  final String createdBy;

  Task({
    required this.taskId,
    required this.adminId,
    this.employeeId,
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

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'],
      adminId: json['adminId'] ?? 'NA',
      employeeId: json['employeeId'],
      subject: json['subject'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate'] ?? json['startDate']),
      priority: json['priority'] ?? '',
      relatedTo: json['relatedTo'] ?? '',
      relatedToId: json['relatedToId'] ?? '',
      relatedToName: json['relatedToName'] ?? '',
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      estimatedHours: (json['estimatedHours'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      assignedEmployees: (json['assignedEmployees'] as List? ?? [])
          .map((e) => Employee.fromJson(e))
          .toList(),
      followersEmployees: (json['followersEmployees'] as List? ?? [])
          .map((e) => Employee.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'] ?? '',
    );
  }
}

class Employee {
  final String employeeId;
  final String name;

  Employee({
    required this.employeeId,
    required this.name,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
    };
  }
}
