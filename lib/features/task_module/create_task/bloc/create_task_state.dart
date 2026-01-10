import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/task_module/create_task/model/customer_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/invoice_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/lead_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proform_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/proposal_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/update_task_model.dart';
import 'package:xpertbiz/features/task_module/edit_task/model/get_task_model.dart';

class CreateTaskState extends Equatable {
  /// loading flags
  final bool isLoading; // dropdown / fetch
  final bool isSubmitting; // create / update button
  final bool taskCreated;
  final bool taskUpdated;

  /// error
  final String? errorMessage;

  /// form fields
  final String relatedTo;
  final String priority;
  final String assignee;
  final String follower;

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

  const CreateTaskState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.taskCreated = false,
    this.taskUpdated = false,
    this.errorMessage,
    this.relatedTo = 'Non selected',
    this.priority = 'Non selected',
    this.assignee = 'Non selected',
    this.follower = 'Non selected',
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
  });

  CreateTaskState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? taskCreated,
    bool? taskUpdated,
    String? errorMessage,
    String? relatedTo,
    String? priority,
    String? assignee,
    String? follower,
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
  }) {
    return CreateTaskState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      taskCreated: taskCreated ?? this.taskCreated,
      taskUpdated: taskUpdated ?? this.taskUpdated,
      errorMessage: errorMessage,
      relatedTo: relatedTo ?? this.relatedTo,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      follower: follower ?? this.follower,
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
        priority,
        assignee,
        follower,
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
      ];
}
