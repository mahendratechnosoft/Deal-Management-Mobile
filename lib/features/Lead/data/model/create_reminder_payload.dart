class CreateReminderRequest {
  final String customerName;
  final String message;
  final DateTime triggerTime;
  final String relatedModule;
  final String referenceId;
  final String referenceName;
  final bool sendEmailToCustomer;
  final int repeatDays;
  final int recursionLimit;
  final bool recurring;
  final String employeeId;

  CreateReminderRequest({
    required this.customerName,
    required this.message,
    required this.triggerTime,
    required this.relatedModule,
    required this.referenceId,
    required this.referenceName,
    required this.sendEmailToCustomer,
    required this.repeatDays,
    required this.recursionLimit,
    required this.recurring,
    required this.employeeId,
  });

  Map<String, dynamic> toJson() {
    return {
      "customerName": customerName,
      "message": message,
      "triggerTime": triggerTime.toIso8601String(),
      "relatedModule": relatedModule,
      "referenceId": referenceId,
      "referenceName": referenceName,
      "sendEmailToCustomer": sendEmailToCustomer,
      "repeatDays": repeatDays,
      "recursionLimit": recursionLimit,
      "recurring": recurring,
      "employeeId": employeeId,
    };
  }
}
