class EmployeeItemModel {
  final String employeeId;
  final String name;

  EmployeeItemModel({
    required this.employeeId,
    required this.name,
  });

  factory EmployeeItemModel.fromJson(Map<String, dynamic> json) {
    return EmployeeItemModel(
      employeeId: json['employeeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'name': name,
  };
}
