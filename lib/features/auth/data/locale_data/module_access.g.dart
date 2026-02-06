// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_access.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModuleAccessAdapter extends TypeAdapter<ModuleAccess> {
  @override
  final int typeId = 1;

  @override
  ModuleAccess read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModuleAccess(
      moduleAccessId: fields[0] as String,
      adminId: fields[1] as String?,
      employeeId: fields[2] as String?,
      customerId: fields[3] as String?,
      leadAccess: fields[4] as bool,
      leadViewAll: fields[5] as bool,
      leadCreate: fields[6] as bool,
      leadDelete: fields[7] as bool,
      leadEdit: fields[8] as bool,
      customerAccess: fields[9] as bool,
      customerViewAll: fields[10] as bool,
      customerCreate: fields[11] as bool,
      customerDelete: fields[12] as bool,
      customerEdit: fields[13] as bool,
      proposalAccess: fields[14] as bool,
      proposalViewAll: fields[15] as bool,
      proposalCreate: fields[16] as bool,
      proposalDelete: fields[17] as bool,
      proposalEdit: fields[18] as bool,
      proformaInvoiceAccess: fields[19] as bool,
      proformaInvoiceViewAll: fields[20] as bool,
      proformaInvoiceCreate: fields[21] as bool,
      proformaInvoiceDelete: fields[22] as bool,
      proformaInvoiceEdit: fields[23] as bool,
      invoiceAccess: fields[24] as bool,
      invoiceViewAll: fields[25] as bool,
      invoiceCreate: fields[26] as bool,
      invoiceDelete: fields[27] as bool,
      invoiceEdit: fields[28] as bool,
      paymentAccess: fields[29] as bool,
      paymentViewAll: fields[30] as bool,
      paymentCreate: fields[31] as bool,
      paymentDelete: fields[32] as bool,
      paymentEdit: fields[33] as bool,
      timeSheetAccess: fields[34] as bool,
      timeSheetViewAll: fields[35] as bool,
      timeSheetCreate: fields[36] as bool,
      timeSheetDelete: fields[37] as bool,
      timeSheetEdit: fields[38] as bool,
      donorAccess: fields[39] as bool,
      donorViewAll: fields[40] as bool,
      donorCreate: fields[41] as bool,
      donorDelete: fields[42] as bool,
      donorEdit: fields[43] as bool,
      itemAccess: fields[44] as bool,
      itemViewAll: fields[45] as bool,
      itemCreate: fields[46] as bool,
      itemDelete: fields[47] as bool,
      itemEdit: fields[48] as bool,
      taskAccess: fields[49] as bool,
      taskLogAccess: fields[50] as bool,
      taskViewAll: fields[51] as bool,
      taskCreate: fields[52] as bool,
      taskDelete: fields[53] as bool,
      taskEdit: fields[54] as bool,
      employeeAccess: fields[55] as bool,
      settingAccess: fields[56] as bool,
      amcAccess: fields[57] as bool,
      amcViewAll: fields[58] as bool,
      amcCreate: fields[59] as bool,
      amcDelete: fields[60] as bool,
      amcEdit: fields[61] as bool,
      vendorAccess: fields[62] as bool,
      vendorViewAll: fields[63] as bool,
      vendorCreate: fields[64] as bool,
      vendorDelete: fields[65] as bool,
      vendorEdit: fields[66] as bool,
      complianceAccess: fields[67] as bool,
      complianceViewAll: fields[68] as bool,
      complianceCreate: fields[69] as bool,
      complianceDelete: fields[70] as bool,
      complianceEdit: fields[71] as bool,
      reminderAccess: fields[72] as bool,
      reminderViewAll: fields[73] as bool,
      reminderCreate: fields[74] as bool,
      reminderDelete: fields[75] as bool,
      reminderEdit: fields[76] as bool,
      expenseAccess: fields[77] as bool,
      expenseViewAll: fields[78] as bool,
      expenseCreate: fields[79] as bool,
      expenseDelete: fields[80] as bool,
      expenseEdit: fields[81] as bool,
      holidayCalendarAccess: fields[82] as bool,
      holidayCalendarViewAll: fields[83] as bool,
      holidayCalendarCreate: fields[84] as bool,
      holidayCalendarDelete: fields[85] as bool,
      holidayCalendarEdit: fields[86] as bool,
      leaveRequestAccess: fields[87] as bool,
      leaveRequestViewAll: fields[88] as bool,
      leaveRequestCreate: fields[89] as bool,
      leaveRequestDelete: fields[90] as bool,
      leaveRequestEdit: fields[91] as bool,
      canCustomerLogin: fields[92] as bool,
      canContactPersonLogin: fields[93] as bool,
      customerComplianceAccess: fields[94] as bool,
      customerComplianceViewAll: fields[95] as bool,
      customerComplianceCreate: fields[96] as bool,
      customerComplianceDelete: fields[97] as bool,
      customerComplianceEdit: fields[98] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ModuleAccess obj) {
    writer
      ..writeByte(99)
      ..writeByte(0)
      ..write(obj.moduleAccessId)
      ..writeByte(1)
      ..write(obj.adminId)
      ..writeByte(2)
      ..write(obj.employeeId)
      ..writeByte(3)
      ..write(obj.customerId)
      ..writeByte(4)
      ..write(obj.leadAccess)
      ..writeByte(5)
      ..write(obj.leadViewAll)
      ..writeByte(6)
      ..write(obj.leadCreate)
      ..writeByte(7)
      ..write(obj.leadDelete)
      ..writeByte(8)
      ..write(obj.leadEdit)
      ..writeByte(9)
      ..write(obj.customerAccess)
      ..writeByte(10)
      ..write(obj.customerViewAll)
      ..writeByte(11)
      ..write(obj.customerCreate)
      ..writeByte(12)
      ..write(obj.customerDelete)
      ..writeByte(13)
      ..write(obj.customerEdit)
      ..writeByte(14)
      ..write(obj.proposalAccess)
      ..writeByte(15)
      ..write(obj.proposalViewAll)
      ..writeByte(16)
      ..write(obj.proposalCreate)
      ..writeByte(17)
      ..write(obj.proposalDelete)
      ..writeByte(18)
      ..write(obj.proposalEdit)
      ..writeByte(19)
      ..write(obj.proformaInvoiceAccess)
      ..writeByte(20)
      ..write(obj.proformaInvoiceViewAll)
      ..writeByte(21)
      ..write(obj.proformaInvoiceCreate)
      ..writeByte(22)
      ..write(obj.proformaInvoiceDelete)
      ..writeByte(23)
      ..write(obj.proformaInvoiceEdit)
      ..writeByte(24)
      ..write(obj.invoiceAccess)
      ..writeByte(25)
      ..write(obj.invoiceViewAll)
      ..writeByte(26)
      ..write(obj.invoiceCreate)
      ..writeByte(27)
      ..write(obj.invoiceDelete)
      ..writeByte(28)
      ..write(obj.invoiceEdit)
      ..writeByte(29)
      ..write(obj.paymentAccess)
      ..writeByte(30)
      ..write(obj.paymentViewAll)
      ..writeByte(31)
      ..write(obj.paymentCreate)
      ..writeByte(32)
      ..write(obj.paymentDelete)
      ..writeByte(33)
      ..write(obj.paymentEdit)
      ..writeByte(34)
      ..write(obj.timeSheetAccess)
      ..writeByte(35)
      ..write(obj.timeSheetViewAll)
      ..writeByte(36)
      ..write(obj.timeSheetCreate)
      ..writeByte(37)
      ..write(obj.timeSheetDelete)
      ..writeByte(38)
      ..write(obj.timeSheetEdit)
      ..writeByte(39)
      ..write(obj.donorAccess)
      ..writeByte(40)
      ..write(obj.donorViewAll)
      ..writeByte(41)
      ..write(obj.donorCreate)
      ..writeByte(42)
      ..write(obj.donorDelete)
      ..writeByte(43)
      ..write(obj.donorEdit)
      ..writeByte(44)
      ..write(obj.itemAccess)
      ..writeByte(45)
      ..write(obj.itemViewAll)
      ..writeByte(46)
      ..write(obj.itemCreate)
      ..writeByte(47)
      ..write(obj.itemDelete)
      ..writeByte(48)
      ..write(obj.itemEdit)
      ..writeByte(49)
      ..write(obj.taskAccess)
      ..writeByte(50)
      ..write(obj.taskLogAccess)
      ..writeByte(51)
      ..write(obj.taskViewAll)
      ..writeByte(52)
      ..write(obj.taskCreate)
      ..writeByte(53)
      ..write(obj.taskDelete)
      ..writeByte(54)
      ..write(obj.taskEdit)
      ..writeByte(55)
      ..write(obj.employeeAccess)
      ..writeByte(56)
      ..write(obj.settingAccess)
      ..writeByte(57)
      ..write(obj.amcAccess)
      ..writeByte(58)
      ..write(obj.amcViewAll)
      ..writeByte(59)
      ..write(obj.amcCreate)
      ..writeByte(60)
      ..write(obj.amcDelete)
      ..writeByte(61)
      ..write(obj.amcEdit)
      ..writeByte(62)
      ..write(obj.vendorAccess)
      ..writeByte(63)
      ..write(obj.vendorViewAll)
      ..writeByte(64)
      ..write(obj.vendorCreate)
      ..writeByte(65)
      ..write(obj.vendorDelete)
      ..writeByte(66)
      ..write(obj.vendorEdit)
      ..writeByte(67)
      ..write(obj.complianceAccess)
      ..writeByte(68)
      ..write(obj.complianceViewAll)
      ..writeByte(69)
      ..write(obj.complianceCreate)
      ..writeByte(70)
      ..write(obj.complianceDelete)
      ..writeByte(71)
      ..write(obj.complianceEdit)
      ..writeByte(72)
      ..write(obj.reminderAccess)
      ..writeByte(73)
      ..write(obj.reminderViewAll)
      ..writeByte(74)
      ..write(obj.reminderCreate)
      ..writeByte(75)
      ..write(obj.reminderDelete)
      ..writeByte(76)
      ..write(obj.reminderEdit)
      ..writeByte(77)
      ..write(obj.expenseAccess)
      ..writeByte(78)
      ..write(obj.expenseViewAll)
      ..writeByte(79)
      ..write(obj.expenseCreate)
      ..writeByte(80)
      ..write(obj.expenseDelete)
      ..writeByte(81)
      ..write(obj.expenseEdit)
      ..writeByte(82)
      ..write(obj.holidayCalendarAccess)
      ..writeByte(83)
      ..write(obj.holidayCalendarViewAll)
      ..writeByte(84)
      ..write(obj.holidayCalendarCreate)
      ..writeByte(85)
      ..write(obj.holidayCalendarDelete)
      ..writeByte(86)
      ..write(obj.holidayCalendarEdit)
      ..writeByte(87)
      ..write(obj.leaveRequestAccess)
      ..writeByte(88)
      ..write(obj.leaveRequestViewAll)
      ..writeByte(89)
      ..write(obj.leaveRequestCreate)
      ..writeByte(90)
      ..write(obj.leaveRequestDelete)
      ..writeByte(91)
      ..write(obj.leaveRequestEdit)
      ..writeByte(92)
      ..write(obj.canCustomerLogin)
      ..writeByte(93)
      ..write(obj.canContactPersonLogin)
      ..writeByte(94)
      ..write(obj.customerComplianceAccess)
      ..writeByte(95)
      ..write(obj.customerComplianceViewAll)
      ..writeByte(96)
      ..write(obj.customerComplianceCreate)
      ..writeByte(97)
      ..write(obj.customerComplianceDelete)
      ..writeByte(98)
      ..write(obj.customerComplianceEdit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleAccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
