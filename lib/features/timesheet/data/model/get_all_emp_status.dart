// To parse this JSON data, do
//
//     final getAllEmpStatusModel = getAllEmpStatusModelFromJson(jsonString);

import 'dart:convert';

List<GetAllEmpStatusModel> getAllEmpStatusModelFromJson(String str) => List<GetAllEmpStatusModel>.from(json.decode(str).map((x) => GetAllEmpStatusModel.fromJson(x)));

String getAllEmpStatusModelToJson(List<GetAllEmpStatusModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllEmpStatusModel {
    int? timeStamp;
    String employeeName;
    String role;
    String employeeId;
    String department;
    bool status;

    GetAllEmpStatusModel({
        required this.timeStamp,
        required this.employeeName,
        required this.role,
        required this.employeeId,
        required this.department,
        required this.status,
    });

    factory GetAllEmpStatusModel.fromJson(Map<String, dynamic> json) => GetAllEmpStatusModel(
        timeStamp: json["timeStamp"],
        employeeName: json["employeeName"],
        role: json["role"],
        employeeId: json["employeeId"],
        department: json["department"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "timeStamp": timeStamp,
        "employeeName": employeeName,
        "role": role,
        "employeeId": employeeId,
        "department": department,
        "status": status,
    };
}
