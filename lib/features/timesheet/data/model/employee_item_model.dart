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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeItemModel &&
          runtimeType == other.runtimeType &&
          employeeId == other.employeeId;

  @override
  int get hashCode => employeeId.hashCode;
}
