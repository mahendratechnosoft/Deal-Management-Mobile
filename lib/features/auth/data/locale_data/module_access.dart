import 'package:hive/hive.dart';

part 'module_access.g.dart';

@HiveType(typeId: 1)
class ModuleAccess extends HiveObject {
  @HiveField(0)
  final String moduleAccessId;

  @HiveField(1)
  final String? adminId;

  @HiveField(2)
  final String? employeeId;

  @HiveField(3)
  final String? customerId;

  @HiveField(4)
  final bool leadAccess;

  @HiveField(5)
  final bool leadViewAll;

  @HiveField(6)
  final bool leadCreate;

  @HiveField(7)
  final bool leadDelete;

  @HiveField(8)
  final bool leadEdit;

  @HiveField(9)
  final bool customerAccess;

  @HiveField(10)
  final bool customerViewAll;

  @HiveField(11)
  final bool customerCreate;

  @HiveField(12)
  final bool customerDelete;

  @HiveField(13)
  final bool customerEdit;

  @HiveField(14)
  final bool proposalAccess;

  @HiveField(15)
  final bool proposalViewAll;

  @HiveField(16)
  final bool proposalCreate;

  @HiveField(17)
  final bool proposalDelete;

  @HiveField(18)
  final bool proposalEdit;

  @HiveField(19)
  final bool proformaInvoiceAccess;

  @HiveField(20)
  final bool proformaInvoiceViewAll;

  @HiveField(21)
  final bool proformaInvoiceCreate;

  @HiveField(22)
  final bool proformaInvoiceDelete;

  @HiveField(23)
  final bool proformaInvoiceEdit;

  @HiveField(24)
  final bool invoiceAccess;

  @HiveField(25)
  final bool invoiceViewAll;

  @HiveField(26)
  final bool invoiceCreate;

  @HiveField(27)
  final bool invoiceDelete;

  @HiveField(28)
  final bool invoiceEdit;

  @HiveField(29)
  final bool paymentAccess;

  @HiveField(30)
  final bool paymentViewAll;

  @HiveField(31)
  final bool paymentCreate;

  @HiveField(32)
  final bool paymentDelete;

  @HiveField(33)
  final bool paymentEdit;

  @HiveField(34)
  final bool timeSheetAccess;

  @HiveField(35)
  final bool timeSheetViewAll;

  @HiveField(36)
  final bool timeSheetCreate;

  @HiveField(37)
  final bool timeSheetDelete;

  @HiveField(38)
  final bool timeSheetEdit;

  @HiveField(39)
  final bool donorAccess;

  @HiveField(40)
  final bool donorViewAll;

  @HiveField(41)
  final bool donorCreate;

  @HiveField(42)
  final bool donorDelete;

  @HiveField(43)
  final bool donorEdit;

  @HiveField(44)
  final bool itemAccess;

  @HiveField(45)
  final bool itemViewAll;

  @HiveField(46)
  final bool itemCreate;

  @HiveField(47)
  final bool itemDelete;

  @HiveField(48)
  final bool itemEdit;

  @HiveField(49)
  final bool taskAccess;

  @HiveField(50)
  final bool taskLogAccess;

  @HiveField(51)
  final bool taskViewAll;

  @HiveField(52)
  final bool taskCreate;

  @HiveField(53)
  final bool taskDelete;

  @HiveField(54)
  final bool taskEdit;

  @HiveField(55)
  final bool employeeAccess;

  @HiveField(56)
  final bool settingAccess;

  @HiveField(57)
  final bool amcAccess;

  @HiveField(58)
  final bool amcViewAll;

  @HiveField(59)
  final bool amcCreate;

  @HiveField(60)
  final bool amcDelete;

  @HiveField(61)
  final bool amcEdit;

  @HiveField(62)
  final bool vendorAccess;

  @HiveField(63)
  final bool vendorViewAll;

  @HiveField(64)
  final bool vendorCreate;

  @HiveField(65)
  final bool vendorDelete;

  @HiveField(66)
  final bool vendorEdit;

  @HiveField(67)
  final bool complianceAccess;

  @HiveField(68)
  final bool complianceViewAll;

  @HiveField(69)
  final bool complianceCreate;

  @HiveField(70)
  final bool complianceDelete;

  @HiveField(71)
  final bool complianceEdit;

  @HiveField(72)
  final bool reminderAccess;

  @HiveField(73)
  final bool reminderViewAll;

  @HiveField(74)
  final bool reminderCreate;

  @HiveField(75)
  final bool reminderDelete;

  @HiveField(76)
  final bool reminderEdit;

  @HiveField(77)
  final bool expenseAccess;

  @HiveField(78)
  final bool expenseViewAll;

  @HiveField(79)
  final bool expenseCreate;

  @HiveField(80)
  final bool expenseDelete;

  @HiveField(81)
  final bool expenseEdit;

  @HiveField(82)
  final bool holidayCalendarAccess;

  @HiveField(83)
  final bool holidayCalendarViewAll;

  @HiveField(84)
  final bool holidayCalendarCreate;

  @HiveField(85)
  final bool holidayCalendarDelete;

  @HiveField(86)
  final bool holidayCalendarEdit;

  @HiveField(87)
  final bool leaveRequestAccess;

  @HiveField(88)
  final bool leaveRequestViewAll;

  @HiveField(89)
  final bool leaveRequestCreate;

  @HiveField(90)
  final bool leaveRequestDelete;

  @HiveField(91)
  final bool leaveRequestEdit;

  @HiveField(92)
  final bool canCustomerLogin;

  @HiveField(93)
  final bool canContactPersonLogin;

  @HiveField(94)
  final bool customerComplianceAccess;

  @HiveField(95)
  final bool customerComplianceViewAll;

  @HiveField(96)
  final bool customerComplianceCreate;

  @HiveField(97)
  final bool customerComplianceDelete;

  @HiveField(98)
  final bool customerComplianceEdit;

  ModuleAccess({
    required this.moduleAccessId,
    this.adminId,
    this.employeeId,
    this.customerId,
    required this.leadAccess,
    required this.leadViewAll,
    required this.leadCreate,
    required this.leadDelete,
    required this.leadEdit,
    required this.customerAccess,
    required this.customerViewAll,
    required this.customerCreate,
    required this.customerDelete,
    required this.customerEdit,
    required this.proposalAccess,
    required this.proposalViewAll,
    required this.proposalCreate,
    required this.proposalDelete,
    required this.proposalEdit,
    required this.proformaInvoiceAccess,
    required this.proformaInvoiceViewAll,
    required this.proformaInvoiceCreate,
    required this.proformaInvoiceDelete,
    required this.proformaInvoiceEdit,
    required this.invoiceAccess,
    required this.invoiceViewAll,
    required this.invoiceCreate,
    required this.invoiceDelete,
    required this.invoiceEdit,
    required this.paymentAccess,
    required this.paymentViewAll,
    required this.paymentCreate,
    required this.paymentDelete,
    required this.paymentEdit,
    required this.timeSheetAccess,
    required this.timeSheetViewAll,
    required this.timeSheetCreate,
    required this.timeSheetDelete,
    required this.timeSheetEdit,
    required this.donorAccess,
    required this.donorViewAll,
    required this.donorCreate,
    required this.donorDelete,
    required this.donorEdit,
    required this.itemAccess,
    required this.itemViewAll,
    required this.itemCreate,
    required this.itemDelete,
    required this.itemEdit,
    required this.taskAccess,
    required this.taskLogAccess,
    required this.taskViewAll,
    required this.taskCreate,
    required this.taskDelete,
    required this.taskEdit,
    required this.employeeAccess,
    required this.settingAccess,
    required this.amcAccess,
    required this.amcViewAll,
    required this.amcCreate,
    required this.amcDelete,
    required this.amcEdit,
    required this.vendorAccess,
    required this.vendorViewAll,
    required this.vendorCreate,
    required this.vendorDelete,
    required this.vendorEdit,
    required this.complianceAccess,
    required this.complianceViewAll,
    required this.complianceCreate,
    required this.complianceDelete,
    required this.complianceEdit,
    required this.reminderAccess,
    required this.reminderViewAll,
    required this.reminderCreate,
    required this.reminderDelete,
    required this.reminderEdit,
    required this.expenseAccess,
    required this.expenseViewAll,
    required this.expenseCreate,
    required this.expenseDelete,
    required this.expenseEdit,
    required this.holidayCalendarAccess,
    required this.holidayCalendarViewAll,
    required this.holidayCalendarCreate,
    required this.holidayCalendarDelete,
    required this.holidayCalendarEdit,
    required this.leaveRequestAccess,
    required this.leaveRequestViewAll,
    required this.leaveRequestCreate,
    required this.leaveRequestDelete,
    required this.leaveRequestEdit,
    required this.canCustomerLogin,
    required this.canContactPersonLogin,
    required this.customerComplianceAccess,
    required this.customerComplianceViewAll,
    required this.customerComplianceCreate,
    required this.customerComplianceDelete,
    required this.customerComplianceEdit,
  });

  factory ModuleAccess.fromJson(Map<String, dynamic> json) {
    return ModuleAccess(
      moduleAccessId: json['moduleAccessId'],
      adminId: json['adminId'],
      employeeId: json['employeeId'],
      customerId: json['customerId'],
      leadAccess: json['leadAccess'] ?? false,
      leadViewAll: json['leadViewAll'] ?? false,
      leadCreate: json['leadCreate'] ?? false,
      leadDelete: json['leadDelete'] ?? false,
      leadEdit: json['leadEdit'] ?? false,
      customerAccess: json['customerAccess'] ?? false,
      customerViewAll: json['customerViewAll'] ?? false,
      customerCreate: json['customerCreate'] ?? false,
      customerDelete: json['customerDelete'] ?? false,
      customerEdit: json['customerEdit'] ?? false,
      proposalAccess: json['proposalAccess'] ?? false,
      proposalViewAll: json['proposalViewAll'] ?? false,
      proposalCreate: json['proposalCreate'] ?? false,
      proposalDelete: json['proposalDelete'] ?? false,
      proposalEdit: json['proposalEdit'] ?? false,
      proformaInvoiceAccess: json['proformaInvoiceAccess'] ?? false,
      proformaInvoiceViewAll: json['proformaInvoiceViewAll'] ?? false,
      proformaInvoiceCreate: json['proformaInvoiceCreate'] ?? false,
      proformaInvoiceDelete: json['proformaInvoiceDelete'] ?? false,
      proformaInvoiceEdit: json['proformaInvoiceEdit'] ?? false,
      invoiceAccess: json['invoiceAccess'] ?? false,
      invoiceViewAll: json['invoiceViewAll'] ?? false,
      invoiceCreate: json['invoiceCreate'] ?? false,
      invoiceDelete: json['invoiceDelete'] ?? false,
      invoiceEdit: json['invoiceEdit'] ?? false,
      paymentAccess: json['paymentAccess'] ?? false,
      paymentViewAll: json['paymentViewAll'] ?? false,
      paymentCreate: json['paymentCreate'] ?? false,
      paymentDelete: json['paymentDelete'] ?? false,
      paymentEdit: json['paymentEdit'] ?? false,
      timeSheetAccess: json['timeSheetAccess'] ?? false,
      timeSheetViewAll: json['timeSheetViewAll'] ?? false,
      timeSheetCreate: json['timeSheetCreate'] ?? false,
      timeSheetDelete: json['timeSheetDelete'] ?? false,
      timeSheetEdit: json['timeSheetEdit'] ?? false,
      donorAccess: json['donorAccess'] ?? false,
      donorViewAll: json['donorViewAll'] ?? false,
      donorCreate: json['donorCreate'] ?? false,
      donorDelete: json['donorDelete'] ?? false,
      donorEdit: json['donorEdit'] ?? false,
      itemAccess: json['itemAccess'] ?? false,
      itemViewAll: json['itemViewAll'] ?? false,
      itemCreate: json['itemCreate'] ?? false,
      itemDelete: json['itemDelete'] ?? false,
      itemEdit: json['itemEdit'] ?? false,
      taskAccess: json['taskAccess'] ?? false,
      taskLogAccess: json['taskLogAccess'] ?? false,
      taskViewAll: json['taskViewAll'] ?? false,
      taskCreate: json['taskCreate'] ?? false,
      taskDelete: json['taskDelete'] ?? false,
      taskEdit: json['taskEdit'] ?? false,
      employeeAccess: json['employeeAccess'] ?? false,
      settingAccess: json['settingAccess'] ?? false,
      amcAccess: json['amcAccess'] ?? false,
      amcViewAll: json['amcViewAll'] ?? false,
      amcCreate: json['amcCreate'] ?? false,
      amcDelete: json['amcDelete'] ?? false,
      amcEdit: json['amcEdit'] ?? false,
      vendorAccess: json['vendorAccess'] ?? false,
      vendorViewAll: json['vendorViewAll'] ?? false,
      vendorCreate: json['vendorCreate'] ?? false,
      vendorDelete: json['vendorDelete'] ?? false,
      vendorEdit: json['vendorEdit'] ?? false,
      complianceAccess: json['complianceAccess'] ?? false,
      complianceViewAll: json['complianceViewAll'] ?? false,
      complianceCreate: json['complianceCreate'] ?? false,
      complianceDelete: json['complianceDelete'] ?? false,
      complianceEdit: json['complianceEdit'] ?? false,
      reminderAccess: json['reminderAccess'] ?? false,
      reminderViewAll: json['reminderViewAll'] ?? false,
      reminderCreate: json['reminderCreate'] ?? false,
      reminderDelete: json['reminderDelete'] ?? false,
      reminderEdit: json['reminderEdit'] ?? false,
      expenseAccess: json['expenseAccess'] ?? false,
      expenseViewAll: json['expenseViewAll'] ?? false,
      expenseCreate: json['expenseCreate'] ?? false,
      expenseDelete: json['expenseDelete'] ?? false,
      expenseEdit: json['expenseEdit'] ?? false,
      holidayCalendarAccess: json['holidayCalendarAccess'] ?? false,
      holidayCalendarViewAll: json['holidayCalendarViewAll'] ?? false,
      holidayCalendarCreate: json['holidayCalendarCreate'] ?? false,
      holidayCalendarDelete: json['holidayCalendarDelete'] ?? false,
      holidayCalendarEdit: json['holidayCalendarEdit'] ?? false,
      leaveRequestAccess: json['leaveRequestAccess'] ?? false,
      leaveRequestViewAll: json['leaveRequestViewAll'] ?? false,
      leaveRequestCreate: json['leaveRequestCreate'] ?? false,
      leaveRequestDelete: json['leaveRequestDelete'] ?? false,
      leaveRequestEdit: json['leaveRequestEdit'] ?? false,
      canCustomerLogin: json['canCustomerLogin'] ?? false,
      canContactPersonLogin: json['canContactPersonLogin'] ?? false,
      customerComplianceAccess: json['customerComplianceAccess'] ?? false,
      customerComplianceViewAll: json['customerComplianceViewAll'] ?? false,
      customerComplianceCreate: json['customerComplianceCreate'] ?? false,
      customerComplianceDelete: json['customerComplianceDelete'] ?? false,
      customerComplianceEdit: json['customerComplianceEdit'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleAccessId': moduleAccessId,
      'adminId': adminId,
      'employeeId': employeeId,
      'customerId': customerId,
      'leadAccess': leadAccess,
      'leadViewAll': leadViewAll,
      'leadCreate': leadCreate,
      'leadDelete': leadDelete,
      'leadEdit': leadEdit,
      'customerAccess': customerAccess,
      'customerViewAll': customerViewAll,
      'customerCreate': customerCreate,
      'customerDelete': customerDelete,
      'customerEdit': customerEdit,
      'proposalAccess': proposalAccess,
      'proposalViewAll': proposalViewAll,
      'proposalCreate': proposalCreate,
      'proposalDelete': proposalDelete,
      'proposalEdit': proposalEdit,
      'proformaInvoiceAccess': proformaInvoiceAccess,
      'proformaInvoiceViewAll': proformaInvoiceViewAll,
      'proformaInvoiceCreate': proformaInvoiceCreate,
      'proformaInvoiceDelete': proformaInvoiceDelete,
      'proformaInvoiceEdit': proformaInvoiceEdit,
      'invoiceAccess': invoiceAccess,
      'invoiceViewAll': invoiceViewAll,
      'invoiceCreate': invoiceCreate,
      'invoiceDelete': invoiceDelete,
      'invoiceEdit': invoiceEdit,
      'paymentAccess': paymentAccess,
      'paymentViewAll': paymentViewAll,
      'paymentCreate': paymentCreate,
      'paymentDelete': paymentDelete,
      'paymentEdit': paymentEdit,
      'timeSheetAccess': timeSheetAccess,
      'timeSheetViewAll': timeSheetViewAll,
      'timeSheetCreate': timeSheetCreate,
      'timeSheetDelete': timeSheetDelete,
      'timeSheetEdit': timeSheetEdit,
      'donorAccess': donorAccess,
      'donorViewAll': donorViewAll,
      'donorCreate': donorCreate,
      'donorDelete': donorDelete,
      'donorEdit': donorEdit,
      'itemAccess': itemAccess,
      'itemViewAll': itemViewAll,
      'itemCreate': itemCreate,
      'itemDelete': itemDelete,
      'itemEdit': itemEdit,
      'taskAccess': taskAccess,
      'taskLogAccess': taskLogAccess,
      'taskViewAll': taskViewAll,
      'taskCreate': taskCreate,
      'taskDelete': taskDelete,
      'taskEdit': taskEdit,
      'employeeAccess': employeeAccess,
      'settingAccess': settingAccess,
      'amcAccess': amcAccess,
      'amcViewAll': amcViewAll,
      'amcCreate': amcCreate,
      'amcDelete': amcDelete,
      'amcEdit': amcEdit,
      'vendorAccess': vendorAccess,
      'vendorViewAll': vendorViewAll,
      'vendorCreate': vendorCreate,
      'vendorDelete': vendorDelete,
      'vendorEdit': vendorEdit,
      'complianceAccess': complianceAccess,
      'complianceViewAll': complianceViewAll,
      'complianceCreate': complianceCreate,
      'complianceDelete': complianceDelete,
      'complianceEdit': complianceEdit,
      'reminderAccess': reminderAccess,
      'reminderViewAll': reminderViewAll,
      'reminderCreate': reminderCreate,
      'reminderDelete': reminderDelete,
      'reminderEdit': reminderEdit,
      'expenseAccess': expenseAccess,
      'expenseViewAll': expenseViewAll,
      'expenseCreate': expenseCreate,
      'expenseDelete': expenseDelete,
      'expenseEdit': expenseEdit,
      'holidayCalendarAccess': holidayCalendarAccess,
      'holidayCalendarViewAll': holidayCalendarViewAll,
      'holidayCalendarCreate': holidayCalendarCreate,
      'holidayCalendarDelete': holidayCalendarDelete,
      'holidayCalendarEdit': holidayCalendarEdit,
      'leaveRequestAccess': leaveRequestAccess,
      'leaveRequestViewAll': leaveRequestViewAll,
      'leaveRequestCreate': leaveRequestCreate,
      'leaveRequestDelete': leaveRequestDelete,
      'leaveRequestEdit': leaveRequestEdit,
      'canCustomerLogin': canCustomerLogin,
      'canContactPersonLogin': canContactPersonLogin,
      'customerComplianceAccess': customerComplianceAccess,
      'customerComplianceViewAll': customerComplianceViewAll,
      'customerComplianceCreate': customerComplianceCreate,
      'customerComplianceDelete': customerComplianceDelete,
      'customerComplianceEdit': customerComplianceEdit,
    };
  }
}