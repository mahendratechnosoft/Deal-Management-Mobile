class AddAssigneeRequest {
  final String taskId;
  final List<String> employeeIds;

  AddAssigneeRequest({
    required this.taskId,
    required this.employeeIds,
  });

  Map<String, dynamic> toJson() => {
    "taskId": taskId,
    "employeeIds": employeeIds,
  };
}