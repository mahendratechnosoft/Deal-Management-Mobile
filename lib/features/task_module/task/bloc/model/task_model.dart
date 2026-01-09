class TaskModel {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String startDate;
  final String endDate;
  final String assignee;

  const TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.assignee,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      priority: json['priority'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      assignee: json['assignee'],
    );
  }
}
