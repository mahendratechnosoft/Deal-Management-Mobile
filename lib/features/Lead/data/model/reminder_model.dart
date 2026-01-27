import 'dart:convert';

/// ================= PARSE HELPERS =================

List<ReminderModel> reminderModelFromJson(String str) =>
    List<ReminderModel>.from(
      json.decode(str).map((x) => ReminderModel.fromJson(x)),
    );

String reminderModelToJson(List<ReminderModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// ================= MODEL =================

class ReminderModel {
  final String reminderId;
  final String adminId;
  final String employeeId;
  final String customerName;
  final String message;
  final DateTime triggerTime;
  final String relatedModule;
  final String referenceId;
  final String referenceName;
  final bool sendEmailToCustomer;
  final int repeatDays;
  final int recursionLimit;
  final int currentCount;
  final String createdBy;
  final DateTime createdAt;
  final bool recurring;
  final bool sent;

  ReminderModel({
    required this.reminderId,
    required this.adminId,
    required this.employeeId,
    required this.customerName,
    required this.message,
    required this.triggerTime,
    required this.relatedModule,
    required this.referenceId,
    required this.referenceName,
    required this.sendEmailToCustomer,
    required this.repeatDays,
    required this.recursionLimit,
    required this.currentCount,
    required this.createdBy,
    required this.createdAt,
    required this.recurring,
    required this.sent,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) =>
      ReminderModel(
        reminderId: json['reminderId'] as String? ?? '',
        adminId: json['adminId'] as String? ?? '',
        employeeId: json['employeeId'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        message: json['message'] as String? ?? '',
        triggerTime: _parseDate(json['triggerTime']),
        relatedModule: json['relatedModule'] as String? ?? '',
        referenceId: json['referenceId'] as String? ?? '',
        referenceName: json['referenceName'] as String? ?? '',
        sendEmailToCustomer:
            json['sendEmailToCustomer'] as bool? ?? false,
        repeatDays: _parseInt(json['repeatDays']),
        recursionLimit: _parseInt(json['recursionLimit']),
        currentCount: _parseInt(json['currentCount']),
        createdBy: json['createdBy'] as String? ?? '',
        createdAt: _parseDate(json['createdAt']),
        recurring: json['recurring'] as bool? ?? false,
        sent: json['sent'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'reminderId': reminderId,
        'adminId': adminId,
        'employeeId': employeeId,
        'customerName': customerName,
        'message': message,
        'triggerTime': triggerTime.toIso8601String(),
        'relatedModule': relatedModule,
        'referenceId': referenceId,
        'referenceName': referenceName,
        'sendEmailToCustomer': sendEmailToCustomer,
        'repeatDays': repeatDays,
        'recursionLimit': recursionLimit,
        'currentCount': currentCount,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'recurring': recurring,
        'sent': sent,
      };

  /// ================= SAFE PARSERS =================

  static DateTime _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }
}
