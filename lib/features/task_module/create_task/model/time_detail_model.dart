// To parse this JSON data, do
//
//     final timeDetailsModel = timeDetailsModelFromJson(jsonString);

import 'dart:convert';

List<TimeDetailsModel> timeDetailsModelFromJson(String str) =>
    List<TimeDetailsModel>.from(
        json.decode(str).map((x) => TimeDetailsModel.fromJson(x)));

class TimeDetailsModel {
  final String taskLogId;
  final String taskId;
  final String adminId;
  final String? employeeId;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final String endNote;
  final int durationInMinutes;
  final String status;

  TimeDetailsModel({
    required this.taskLogId,
    required this.taskId,
    required this.adminId,
    this.employeeId,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.endNote,
    required this.durationInMinutes,
    required this.status,
  });

  factory TimeDetailsModel.fromJson(Map<String, dynamic> json) {
    return TimeDetailsModel(
      taskLogId: json['taskLogId'] ?? '',
      taskId: json['taskId'] ?? '',
      adminId: json['adminId'] ?? '',
      employeeId: json['employeeId'],
      name: json['name'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] == null || json['endTime'] == ''
          ? null
          : DateTime.parse(json['endTime']),
      endNote: json['endNote'] ?? '',
      durationInMinutes: json['durationInMinutes'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

enum Name { JOHN_DOE }

final nameValues = EnumValues({"John Doe": Name.JOHN_DOE});

enum Status { COMPLETED }

final statusValues = EnumValues({"COMPLETED": Status.COMPLETED});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
