// To parse this JSON data, do
//
//     final leadDetailsModel = leadDetailsModelFromJson(jsonString);

import 'dart:convert';

LeadDetailsModel leadDetailsModelFromJson(String str) =>
    LeadDetailsModel.fromJson(json.decode(str));

String leadDetailsModelToJson(LeadDetailsModel data) =>
    json.encode(data.toJson());

class LeadDetailsModel {
  List<dynamic> leadColumn;
  LeadDetails lead;

  LeadDetailsModel({
    required this.leadColumn,
    required this.lead,
  });

  factory LeadDetailsModel.fromJson(Map<String, dynamic> json) =>
      LeadDetailsModel(
        leadColumn: List<dynamic>.from(json["leadColumn"].map((x) => x)),
        lead: LeadDetails.fromJson(json["lead"]),
      );

  Map<String, dynamic> toJson() => {
        "leadColumn": List<dynamic>.from(leadColumn.map((x) => x)),
        "lead": lead.toJson(),
      };
}

class LeadDetails {
  final String id;
  final String adminId;
  final String? employeeId;
  final String? assignTo;
  final String status;
  final String source;
  final String clientName;
  final String companyName;
  final String? customerId;
  final double revenue;
  final String mobileNumber;
  final String phoneNumber;
  final String email;
  final String website;
  final String industry;
  final String? priority;
  final bool converted;
  final String street;
  final String country;
  final String state;
  final String city;
  final String zipCode;
  final String description;
  final dynamic followUp;
  final DateTime createdDate;
  final DateTime updatedDate;
  final Map<String, dynamic> fields;
  final List<dynamic> columns;

  LeadDetails({
    required this.id,
    required this.adminId,
    required this.employeeId,
    required this.assignTo,
    required this.status,
    required this.source,
    required this.clientName,
    required this.companyName,
    required this.customerId,
    required this.revenue,
    required this.mobileNumber,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.industry,
    required this.priority,
    required this.converted,
    required this.street,
    required this.country,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.description,
    required this.followUp,
    required this.createdDate,
    required this.updatedDate,
    required this.fields,
    required this.columns,
  });

  /// EMPTY FALLBACK (VERY IMPORTANT)
  factory LeadDetails.empty() => LeadDetails(
        id: '',
        adminId: '',
        employeeId: null,
        assignTo: null,
        status: '',
        source: '',
        clientName: '',
        companyName: '',
        customerId: null,
        revenue: 0.0,
        mobileNumber: '',
        phoneNumber: '',
        email: '',
        website: '',
        industry: '',
        priority: null,
        converted: false,
        street: '',
        country: '',
        state: '',
        city: '',
        zipCode: '',
        description: '',
        followUp: null,
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        fields: const {},
        columns: const [],
      );

  factory LeadDetails.fromJson(Map<String, dynamic> json) => LeadDetails(
        id: json["id"] as String? ?? '',
        adminId: json["adminId"] as String? ?? '',
        employeeId: json["employeeId"] as String?,
        assignTo: json["assignTo"] as String?,
        status: json["status"] as String? ?? '',
        source: json["source"] as String? ?? '',
        clientName: json["clientName"] as String? ?? '',
        companyName: json["companyName"] as String? ?? '',
        customerId: json["customerId"] as String?,
        revenue: _parseDouble(json["revenue"]),
        mobileNumber: json["mobileNumber"] as String? ?? '',
        phoneNumber: json["phoneNumber"] as String? ?? '',
        email: json["email"] as String? ?? '',
        website: json["website"] as String? ?? '',
        industry: json["industry"] as String? ?? '',
        priority: json["priority"] as String?,
        converted: json["converted"] as bool? ?? false,
        street: json["street"] as String? ?? '',
        country: json["country"] as String? ?? '',
        state: json["state"] as String? ?? '',
        city: json["city"] as String? ?? '',
        zipCode: json["zipCode"] as String? ?? '',
        description: json["description"] as String? ?? '',
        followUp: json["followUp"],
        createdDate: _parseDate(json["createdDate"]),
        updatedDate: _parseDate(json["updatedDate"]),
        fields: json["fields"] as Map<String, dynamic>? ?? const {},
        columns: json["columns"] as List<dynamic>? ?? const [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "adminId": adminId,
        "employeeId": employeeId,
        "assignTo": assignTo,
        "status": status,
        "source": source,
        "clientName": clientName,
        "companyName": companyName,
        "customerId": customerId,
        "revenue": revenue,
        "mobileNumber": mobileNumber,
        "phoneNumber": phoneNumber,
        "email": email,
        "website": website,
        "industry": industry,
        "priority": priority,
        "converted": converted,
        "street": street,
        "country": country,
        "state": state,
        "city": city,
        "zipCode": zipCode,
        "description": description,
        "followUp": followUp,
        "createdDate": createdDate.toIso8601String(),
        "updatedDate": updatedDate.toIso8601String(),
        "fields": fields,
        "columns": columns,
      };

  // ================= SAFE PARSERS =================

  static DateTime _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
