class LeaveApproverModel {
  final String employeeId;
  final String name;
  final String? email;
  final String? role;

  const LeaveApproverModel({
    required this.employeeId,
    required this.name,
    this.email,
    this.role,
  });

  factory LeaveApproverModel.fromJson(Map<String, dynamic> json) {
    return LeaveApproverModel(
      employeeId: json['employeeId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['employeeName']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'name': name,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveApproverModel &&
          runtimeType == other.runtimeType &&
          employeeId == other.employeeId;

  @override
  int get hashCode => employeeId.hashCode;
}
