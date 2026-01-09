import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/task_module/create_task/model/update_task_model.dart';
import 'package:xpertbiz/features/task_module/edit_task/model/get_task_model.dart';

class CreateTaskState extends Equatable {
  final String relatedTo;
  final String priority;
  final String assignee;
  final String follower;
  final DateTime? startDate;
  final DateTime? dueDate;

  final bool isLoading;
  final bool success;
  final String? errorMessage;

  // 🔥 ADD THIS
  final GetTaskModel? getTaskModel;
  final TaskUpdateModel? taskUpdateModel;

  final List attachments;

  const CreateTaskState({
    this.relatedTo = 'Non selected',
    this.priority = 'Non selected',
    this.assignee = 'Non selected',
    this.follower = 'Non selected',
    this.startDate,
    this.dueDate,
    this.isLoading = false,
    this.success = false,
    this.errorMessage,
    this.getTaskModel,
    this.taskUpdateModel,
    this.attachments = const [],
  });

  CreateTaskState copyWith({
    String? relatedTo,
    String? priority,
    String? assignee,
    String? follower,
    DateTime? startDate,
    DateTime? dueDate,
    bool? isLoading,
    bool? success,
    String? errorMessage,
    GetTaskModel? getTaskModel,
    TaskUpdateModel? taskUpdateModel,
    List? attachments,
  }) {
    return CreateTaskState(
        relatedTo: relatedTo ?? this.relatedTo,
        priority: priority ?? this.priority,
        assignee: assignee ?? this.assignee,
        follower: follower ?? this.follower,
        startDate: startDate ?? this.startDate,
        dueDate: dueDate ?? this.dueDate,
        isLoading: isLoading ?? this.isLoading,
        success: success ?? this.success,
        errorMessage: errorMessage,
        getTaskModel: getTaskModel ?? this.getTaskModel,
        attachments: attachments ?? this.attachments,
        taskUpdateModel: taskUpdateModel ?? this.taskUpdateModel);
  }

  @override
  List<Object?> get props => [
        relatedTo,
        priority,
        assignee,
        follower,
        startDate,
        dueDate,
        isLoading,
        success,
        errorMessage,
        getTaskModel,
        taskUpdateModel,
        attachments,
      ];
}
