import 'dart:convert';

List<GetAllEmpStatusModel> getAllEmpStatusModelFromJson(String str) =>
    List<GetAllEmpStatusModel>.from(
      json.decode(str).map((x) => GetAllEmpStatusModel.fromJson(x)),
    );

String getAllEmpStatusModelToJson(List<GetAllEmpStatusModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllEmpStatusModel {
  final int? timeStamp; // ✅ nullable (IMPORTANT)
  final String employeeName;
  final String role;
  final String employeeId;
  final String department;
  final bool status;

  const GetAllEmpStatusModel({
    required this.timeStamp,
    required this.employeeName,
    required this.role,
    required this.employeeId,
    required this.department,
    required this.status,
  });

  factory GetAllEmpStatusModel.fromJson(Map<String, dynamic> json) {
    return GetAllEmpStatusModel(
      timeStamp: json['timeStamp'], // keep null as null
      employeeName: json['employeeName'] ?? '',
      role: json['role'] ?? '',
      employeeId: json['employeeId'] ?? '',
      department: json['department'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'timeStamp': timeStamp,
        'employeeName': employeeName,
        'role': role,
        'employeeId': employeeId,
        'department': department,
        'status': status,
      };
}
