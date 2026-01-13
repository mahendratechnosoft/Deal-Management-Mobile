import 'package:xpertbiz/features/auth/bloc/user_role.dart';

class ApiConstants {
  static const String boxName = 'loginResponse';
  static const String userKey = 'currentUser';
  static const String poppinsFont = 'Poppins';

  static const String baseUrl = "http://91.203.133.210:9091/";

  // ================= AUTH =================
  static const String login = "signin";

  // ================= TASK =================
  static String get getTask =>
      "/${RoleResolver.rolePath}/getAllTaskList/";

  static String get getPertucularTAsk =>
      "${RoleResolver.rolePath}/getTaskByItemId/";

  static String get createTask =>
      "/${RoleResolver.rolePath}/createTask";

  static String get taskUpdate =>
      "${RoleResolver.rolePath}/updateTask";

  static String get deleteTask =>
      "${RoleResolver.rolePath}/deleteTask/";

  // ================= ASSIGNEE =================
  static String get assignUrl =>
      "${RoleResolver.rolePath}/getEmployeeNameAndId";

  // ================= TIMER =================
  static String get activeStuseUrl =>
      "${RoleResolver.rolePath}/getActiveTimerForTask";

  static String get timeLogUrl =>
      "${RoleResolver.rolePath}/getAllTimerLogs";

  static String get timerStartUrl =>
      "${RoleResolver.rolePath}/startTimerOfTask";

  static String get timerStopUrl =>
      "${RoleResolver.rolePath}/stopTimerOfTask";

  // ================= RELATED =================
  static String get leadUrl =>
      "${RoleResolver.rolePath}/getLeadNameAndIdWithConverted";

  static String get customerUrl =>
      "${RoleResolver.rolePath}/getCustomerListWithNameAndId";

  static String get proformaUrl =>
      "${RoleResolver.rolePath}/getProformaNumberAndId";

  static String get proposalUrl =>
      "${RoleResolver.rolePath}/getProposalNumberAndId";

  static String get invoiceUrl =>
      "${RoleResolver.rolePath}/getInvoiceNumberAndId";
}
