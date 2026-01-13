import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/task_module/create_task/model/assign_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/check_timer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/customer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/invoice_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/lead_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proform_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proposal_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/time_detail_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/update_task_model.dart';
import 'package:xpertbiz/features/task_module/edit_task/model/get_task_model.dart';

import '../model/start_timer_model.dart';

class CreateTaskState extends Equatable {
  /// loading flags
  final bool isLoading;
  final bool isSubmitting;
  final bool taskCreated;
  final bool taskUpdated;
  final List<TimeDetailsModel> timeDetailsModel;

  /// error
  final String? errorMessage;
  final int elapsedSeconds;
  final CheckTimerStatusModel? checktimerStatus;

  final bool isTimerRunning;
  final TaskLogModel? activeTaskLog;

  /// form fields
  final String relatedTo;
  final String? relatedToId;
  final String priority;
  final String assignee;

  // ✅ FOLLOWER
  final String followerId;
  final String followerName;

  final DateTime? startDate;
  final DateTime? dueDate;

  /// dropdown data
  final List<LeadModel> leadList;
  final List<CustomerModel> customerList;
  final List<ProformModel> proformList;
  final List<ProposalModel> proposalList;
  final List<InvoiceModel> invoiceList;

  /// other data
  final GetTaskModel? getTaskModel;
  final TaskUpdateModel? taskUpdateModel;
  final List<dynamic> attachments;

  /// assignee
  final String assignIdValue;
  final String assignNameValue;

  final List<AssignModel> assigneesList;
  final bool isAssigneesLoading;

  const CreateTaskState({
    this.timeDetailsModel = const [],
    this.checktimerStatus,
    this.elapsedSeconds = 0,
    this.isTimerRunning = false,
    this.activeTaskLog,
    this.isLoading = false,
    this.isSubmitting = false,
    this.taskCreated = false,
    this.taskUpdated = false,
    this.errorMessage,
    this.relatedTo = 'Non selected',
    this.relatedToId,
    this.priority = 'Non selected',
    this.assignee = 'Non selected',

    //

    // ✅ follower defaults
    this.followerId = '',
    this.followerName = 'Select Follower',
    this.startDate,
    this.dueDate,
    this.leadList = const [],
    this.customerList = const [],
    this.proformList = const [],
    this.proposalList = const [],
    this.invoiceList = const [],
    this.getTaskModel,
    this.taskUpdateModel,
    this.attachments = const [],
    this.assignIdValue = '',
    this.assignNameValue = 'Select Assign',
    this.assigneesList = const [],
    this.isAssigneesLoading = false,
  });

  CreateTaskState copyWith({
    List<TimeDetailsModel>? timeDetailsModel,
    CheckTimerStatusModel? checktimerStatus,
    int? elapsedSeconds,
    bool? isTimerRunning,
    TaskLogModel? activeTaskLog,
    bool? isLoading,
    bool? isSubmitting,
    bool? taskCreated,
    bool? taskUpdated,
    String? errorMessage,
    String? relatedTo,
    String? relatedToId,
    String? priority,
    String? assignee,

    // ✅ follower
    String? followerId,
    String? followerName,
    DateTime? startDate,
    DateTime? dueDate,
    List<LeadModel>? leadList,
    List<CustomerModel>? customerList,
    List<ProformModel>? proformList,
    List<ProposalModel>? proposalList,
    List<InvoiceModel>? invoiceList,
    GetTaskModel? getTaskModel,
    TaskUpdateModel? taskUpdateModel,
    List<dynamic>? attachments,
    String? assignIdValue,
    String? assignNameValue,
    bool? isAssigneesLoading,
    List<AssignModel>? assigneesList,
  }) {
    return CreateTaskState(
      timeDetailsModel: timeDetailsModel ?? this.timeDetailsModel,
      checktimerStatus: checktimerStatus,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      activeTaskLog: activeTaskLog ?? this.activeTaskLog,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      taskCreated: taskCreated ?? this.taskCreated,
      taskUpdated: taskUpdated ?? this.taskUpdated,
      errorMessage: errorMessage,
      relatedTo: relatedTo ?? this.relatedTo,
      relatedToId: relatedToId ?? this.relatedToId,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,

      // ✅ follower emit
      followerId: followerId ?? this.followerId,
      followerName: followerName ?? this.followerName,

      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      leadList: leadList ?? this.leadList,
      customerList: customerList ?? this.customerList,
      proformList: proformList ?? this.proformList,
      proposalList: proposalList ?? this.proposalList,
      invoiceList: invoiceList ?? this.invoiceList,
      getTaskModel: getTaskModel ?? this.getTaskModel,
      taskUpdateModel: taskUpdateModel ?? this.taskUpdateModel,
      attachments: attachments ?? this.attachments,
      assignIdValue: assignIdValue ?? this.assignIdValue,
      assignNameValue: assignNameValue ?? this.assignNameValue,
      assigneesList: assigneesList ?? this.assigneesList,
      isAssigneesLoading: isAssigneesLoading ?? this.isAssigneesLoading,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        taskCreated,
        taskUpdated,
        errorMessage,
        relatedTo,
        relatedToId,
        priority,
        assignee,

        // ✅ follower
        followerId,
        followerName,

        isTimerRunning,
        activeTaskLog,

        startDate,
        dueDate,
        leadList,
        customerList,
        proformList,
        proposalList,
        invoiceList,
        getTaskModel,
        taskUpdateModel,
        attachments,
        assignIdValue,
        assignNameValue,
        assigneesList,
        elapsedSeconds,
        checktimerStatus,
        isAssigneesLoading,
        timeDetailsModel,
      ];
}
