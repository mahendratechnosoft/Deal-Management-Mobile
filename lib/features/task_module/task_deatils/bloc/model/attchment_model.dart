// To parse this JSON data, do
//
//     final attachmentModel = attachmentModelFromJson(jsonString);

import 'dart:convert';

List<AttachmentModel> attachmentModelFromJson(String str) => List<AttachmentModel>.from(json.decode(str).map((x) => AttachmentModel.fromJson(x)));

String attachmentModelToJson(List<AttachmentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttachmentModel {
    String taskAttachmentId;
    String taskId;
    String fileName;
    String contentType;
    String data;
    DateTime uploadedAt;
    String uploadedBy;

    AttachmentModel({
        required this.taskAttachmentId,
        required this.taskId,
        required this.fileName,
        required this.contentType,
        required this.data,
        required this.uploadedAt,
        required this.uploadedBy,
    });

    factory AttachmentModel.fromJson(Map<String, dynamic> json) => AttachmentModel(
        taskAttachmentId: json["taskAttachmentId"],
        taskId: json["taskId"],
        fileName: json["fileName"],
        contentType: json["contentType"],
        data: json["data"],
        uploadedAt: DateTime.parse(json["uploadedAt"]),
        uploadedBy: json["uploadedBy"],
    );

    Map<String, dynamic> toJson() => {
        "taskAttachmentId": taskAttachmentId,
        "taskId": taskId,
        "fileName": fileName,
        "contentType": contentType,
        "data": data,
        "uploadedAt": uploadedAt.toIso8601String(),
        "uploadedBy": uploadedBy,
    };
}
