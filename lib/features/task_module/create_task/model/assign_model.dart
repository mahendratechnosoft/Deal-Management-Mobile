// To parse this JSON data, do
//
//     final assignModel = assignModelFromJson(jsonString);

import 'dart:convert';

List<AssignModel> assignModelFromJson(String str) => List<AssignModel>.from(
    json.decode(str).map((x) => AssignModel.fromJson(x)));

String assignModelToJson(List<AssignModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AssignModel {
  final String name;
  final String employeeId;

  AssignModel({
    required this.name,
    required this.employeeId,
  });

  factory AssignModel.fromJson(Map<String, dynamic> json) => AssignModel(
        name: json["name"],
        employeeId: json["employeeId"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "employeeId": employeeId,
      };
}
