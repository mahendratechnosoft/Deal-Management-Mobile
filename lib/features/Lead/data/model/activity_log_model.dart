import 'dart:convert';

List<ActivityLogModel> activityLogModelFromJson(String str) =>
    List<ActivityLogModel>.from(
        json.decode(str).map((x) => ActivityLogModel.fromJson(x)));

String activityLogModelToJson(List<ActivityLogModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActivityLogModel {
  String activityId;
  String adminId;
  String moduleType;
  String moduleId;
  String createdBy;
  DateTime createdDateTime;
  String description;

  ActivityLogModel({
    required this.activityId,
    required this.adminId,
    required this.moduleType,
    required this.moduleId,
    required this.createdBy,
    required this.createdDateTime,
    required this.description,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      ActivityLogModel(
        activityId: json["activityId"] as String? ?? '',
        adminId: json["adminId"] as String? ?? '',
        moduleType: json["moduleType"] as String? ?? '',
        moduleId: json["moduleId"] as String? ?? '',
        createdBy: json["createdBy"] as String? ?? '',
        createdDateTime: _parseDate(json["createdDateTime"]),
        description: json["description"] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        "activityId": activityId,
        "adminId": adminId,
        "moduleType": moduleType,
        "moduleId": moduleId,
        "createdBy": createdBy,
        "createdDateTime": createdDateTime.toIso8601String(),
        "description": description,
      };

  static DateTime _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
