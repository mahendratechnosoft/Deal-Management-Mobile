class CreateTaskRequest {
  final Task task;
  final List<TaskAttachment> taskAttachments;

  CreateTaskRequest({required this.task, required this.taskAttachments});

  Map<String, dynamic> toJson() => {
        "task": task.toJson(),
        "taskAttachments": taskAttachments.map((e) => e.toJson()).toList(),
      };
}

class Task {
  final String subject;
  final String startDate;
  final String endDate;
  final String priority;
  final String relatedTo;
  final String relatedToId;
  final String relatedToName;
  final double hourlyRate;
  final double estimatedHours;
  final String description;
  final List<Employee> assignedEmployees;
  final List<Employee> followersEmployees;

  Task({
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
    required this.assignedEmployees,
    required this.followersEmployees,
  });

  Map<String, dynamic> toJson() => {
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
        "assignedEmployees": assignedEmployees.map((e) => e.toJson()).toList(),
        "followersEmployees": followersEmployees.map((e) => e.toJson()).toList(),
      };
}

class Employee {
  final String employeeId;
  final String name;

  Employee({required this.employeeId, required this.name});

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "name": name,
      };
}

class TaskAttachment {
  final String fileName;
  final String contentType;
  final String data;

  TaskAttachment({
    required this.fileName,
    required this.contentType,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "contentType": contentType,
        "data": data,
      };
}
