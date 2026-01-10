import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_model.dart';
import 'package:xpertbiz/features/task_module/create_task/model/request_task_update_model.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();

  @override
  List<Object?> get props => [];
}

class RelatedChange extends CreateTaskEvent {
  final String value;

  const RelatedChange(this.value);

  @override
  List<Object?> get props => [value];
}

class PriorityChange extends CreateTaskEvent {
  final String value;

  const PriorityChange(this.value);

  @override
  List<Object?> get props => [value];
}

class AssigneeChange extends CreateTaskEvent {
  final String value;
  const AssigneeChange(this.value);

  @override
  List<Object?> get props => [value];
}

class FollowerChange extends CreateTaskEvent {
  final String value;

  const FollowerChange(this.value);

  @override
  List<Object?> get props => [value];
}

class TaskStartDateChanged extends CreateTaskEvent {
  final DateTime date;
  const TaskStartDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class TaskDueDateChanged extends CreateTaskEvent {
  final DateTime date;
  const TaskDueDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class AttachmentsChanged extends CreateTaskEvent {
  final List attachments;

  const AttachmentsChanged(this.attachments);

  @override
  List<Object?> get props => [attachments];
}

class SubmitCreateTask extends CreateTaskEvent {
  final CreateTaskRequest request;

  const SubmitCreateTask({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

class GetTaskEvent extends CreateTaskEvent {
  final String taskId;
  const GetTaskEvent({required this.taskId});
}

class UpdateTaskEvent extends CreateTaskEvent {
  final TaskUpdateRequest request;
  const UpdateTaskEvent({required this.request});
}

class FetchAssignEvent extends CreateTaskEvent {
  final String value;
  const FetchAssignEvent({required this.value});
}
