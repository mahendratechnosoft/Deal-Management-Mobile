import 'package:xpertbiz/features/auth/bloc/user_role.dart';

class ApiConstants {
  static const String boxName = 'loginResponse';
  static const String userKey = 'currentUser';
  static const String poppinsFont = 'Poppins';
  static const String baseUrl = 'https://api.mtechnosoft.xpertbizsolutions.com/';//"http://91.203.133.210:9091/"; //https://api.mtechnosoft.xpertbizsolutions.com/
  
  static const String login = "signin";
  static String get getTask => "/${RoleResolver.rolePath}/getAllTaskList/";
  static String get getPertucularTAsk => "${RoleResolver.rolePath}/getTaskByItemId/";
  static String get createTask => "/${RoleResolver.rolePath}/createTask";
  static String get taskUpdate => "${RoleResolver.rolePath}/updateTask";
  static String get deleteTask => "${RoleResolver.rolePath}/deleteTask/";
  static String get assignUrl => "${RoleResolver.rolePath}/getEmployeeNameAndId";
  static String get activeStuseUrl => "${RoleResolver.rolePath}/getActiveTimerForTask";
  static String get timeLogUrl => "${RoleResolver.rolePath}/getAllTimerLogs";
  static String get timerStartUrl => "${RoleResolver.rolePath}/startTimerOfTask";
  static String get timerStopUrl => "${RoleResolver.rolePath}/stopTimerOfTask";
  static String get leadUrl => "${RoleResolver.rolePath}/getLeadNameAndIdWithConverted";
  static String get customerUrl => "${RoleResolver.rolePath}/getCustomerListWithNameAndId";
  static String get proformaUrl => "${RoleResolver.rolePath}/getProformaNumberAndId";
  static String get proposalUrl => "${RoleResolver.rolePath}/getProposalNumberAndId";
  static String get invoiceUrl =>  "${RoleResolver.rolePath}/getInvoiceNumberAndId";
  static String get addCommentUrl =>  "${RoleResolver.rolePath}/addCommentOnTask";
  static String get getCommentUrl =>  "${RoleResolver.rolePath}/getAllCommentsByTaskId";
  static String get addDocUrl =>  "${RoleResolver.rolePath}/addTaskAttachement";
  static String get getAttchmentUrl =>  "${RoleResolver.rolePath}/getTaskAttachmentByTaskId";
  static String get addAssignees => "${RoleResolver.rolePath}/addAssigneesToTask";
  static String get addFollowers => "${RoleResolver.rolePath}/addFollowersToTask";
  static String get updateStatusUrl => "${RoleResolver.rolePath}/updateTaskStatus";
  static String get getAllEmpStatusUrl => "${RoleResolver.rolePath}/getLoginStatusAllEmployee";
  static String get empAttendanceUrl => "${RoleResolver.rolePath}/addAttendance";
  static String get empmonthAtteUrl => "${RoleResolver.rolePath}/getAttendanceBetween"; 
  static String get checkInUrl => "${RoleResolver.rolePath}/addAttendance";
  static String get checkInStatusUrl => "${RoleResolver.rolePath}/getAttendanceBetweenForParticalurEmployee";
  static String get leadStatusUrl => "${RoleResolver.rolePath}/getLeadStatusAndCount";
  static String get allLeadsUrl => "${RoleResolver.rolePath}/getAllLeads";
  static String get allLeadsDetailsUrl => "${RoleResolver.rolePath}/getLeadById";
  static String get activityUrl => "${RoleResolver.rolePath}/getModuleActivity";
  static String get reminderUrl => "${RoleResolver.rolePath}/getAllReminderForSpecificModule/LEAD";
  static String get createReminderUrl => "${RoleResolver.rolePath}/createReminder";
  static String get createLeadUrl => "${RoleResolver.rolePath}/createLead";
  static String get updateLeadUrl => "${RoleResolver.rolePath}/updateLead";
  static String get deleteLeadUrl => "${RoleResolver.rolePath}/deleteLead";
  static String get allCustomerUrl => "${RoleResolver.rolePath}/getAllCustomer";
  static String get getContactsUrl => "${RoleResolver.rolePath}/getContacts";
  static String get createCustomerUrl => "${RoleResolver.rolePath}/createCustomer";
  static String get updateCustomerUrl => "${RoleResolver.rolePath}/updateCustomer";
  static String get getCustomerDetailsUrl => "${RoleResolver.rolePath}/getCustomerById";
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  










}
