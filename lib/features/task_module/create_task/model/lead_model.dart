// To parse this JSON data, do
//
//     final leadModel = leadModelFromJson(jsonString);

import 'dart:convert';

List<LeadModel> leadModelFromJson(String str) => List<LeadModel>.from(json.decode(str).map((x) => LeadModel.fromJson(x)));

String leadModelToJson(List<LeadModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeadModel {
    String clientName;
    String leadId;
    String companyName;

    LeadModel({
        required this.clientName,
        required this.leadId,
        required this.companyName,
    });

    factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        clientName: json["clientName"],
        leadId: json["leadId"],
        companyName: json["companyName"],
    );

    Map<String, dynamic> toJson() => {
        "clientName": clientName,
        "leadId": leadId,
        "companyName": companyName,
    };
}
