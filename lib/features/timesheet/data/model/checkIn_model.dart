// To parse this JSON data, do
//
//     final checkInModel = checkInModelFromJson(jsonString);

import 'dart:convert';

CheckInModel checkInModelFromJson(String str) => CheckInModel.fromJson(json.decode(str));

String checkInModelToJson(CheckInModel data) => json.encode(data.toJson());

class CheckInModel {
    String attendanceId;
    String adminId;
    String employeeId;
    int timeStamp;
    bool status;

    CheckInModel({
        required this.attendanceId,
        required this.adminId,
        required this.employeeId,
        required this.timeStamp,
        required this.status,
    });

    factory CheckInModel.fromJson(Map<String, dynamic> json) => CheckInModel(
        attendanceId: json["attendanceId"],
        adminId: json["adminId"],
        employeeId: json["employeeId"],
        timeStamp: json["timeStamp"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "attendanceId": attendanceId,
        "adminId": adminId,
        "employeeId": employeeId,
        "timeStamp": timeStamp,
        "status": status,
    };
}
