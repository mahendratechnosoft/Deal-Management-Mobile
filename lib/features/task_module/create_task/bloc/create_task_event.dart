import 'package:equatable/equatable.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/task_module/create_task/model/add_comment.dart';
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

class DependsLelatedtoEvent extends CreateTaskEvent {
  final DropdownItem value;
  const DependsLelatedtoEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class FollowerChange extends CreateTaskEvent {
  final String name;
  final String id;

  const FollowerChange(this.name, this.id);

  @override
  List<Object?> get props => [name, id];
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

class StatusEvent extends CreateTaskEvent {
  final String status;
  const StatusEvent(this.status);
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

class FetchListEvent extends CreateTaskEvent {
  final String value;
  const FetchListEvent({required this.value});
}

class AssigneesDropDownEvent extends CreateTaskEvent {
  final String id;
  final String name;
  const AssigneesDropDownEvent({required this.id, required this.name});
}

// create_task_event.dart
class LoadAssigneesEvent extends CreateTaskEvent {}

class StartTaskTimerEvent extends CreateTaskEvent {
  final String taskId;
  const StartTaskTimerEvent(this.taskId);
}

class StopTaskTimerEvent extends CreateTaskEvent {
  final String taskId;
  final String comment;
  const StopTaskTimerEvent(this.taskId, this.comment);
}

class TimerTickEvent extends CreateTaskEvent {}

class TimerStatusEvent extends CreateTaskEvent {
  final String taskId;
  const TimerStatusEvent({required this.taskId});
}

class TimerDetailsEvent extends CreateTaskEvent {
  final String taskId;
  const TimerDetailsEvent({required this.taskId});
}

// create_task_event.dart (add these events)
class LoadCommentsEvent extends CreateTaskEvent {
  final String taskId;
  const LoadCommentsEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class AddCommentEvent extends CreateTaskEvent {
  final String taskId;
  final String content;
  final List<CommentAttachment> attachments;

  const AddCommentEvent({
    required this.taskId,
    required this.content,
    required this.attachments,
  });

  @override
  List<Object?> get props => [taskId, content, attachments];
}

class RefreshCommentsEvent extends CreateTaskEvent {
  final String taskId;
  const RefreshCommentsEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class AddAssigneeEvent extends CreateTaskEvent {
  final String taskId;
  final List<String> employeeIds;

  const AddAssigneeEvent({
    required this.taskId,
    required this.employeeIds,
  });

  @override
  List<Object?> get props => [taskId, employeeIds];
}

class AddFollowerEvent extends CreateTaskEvent {
  final String taskId;
  final List<String> employeeIds;

  const AddFollowerEvent({
    required this.taskId,
    required this.employeeIds,
  });

  @override
  List<Object?> get props => [taskId, employeeIds];
}

class LoadTaskAssigneesEvent extends CreateTaskEvent {
  final String taskId;
  const LoadTaskAssigneesEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class LoadTaskFollowersEvent extends CreateTaskEvent {
  final String taskId;
  const LoadTaskFollowersEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class AddAssigneeLocal extends CreateTaskEvent {
  final DropdownItem item;
  const AddAssigneeLocal(this.item);
}

class AddFollowerLocal extends CreateTaskEvent {
  final DropdownItem item;
  const AddFollowerLocal(this.item);
}

class RemoveAssigneeLocal extends CreateTaskEvent {
  final String id;
  const RemoveAssigneeLocal(this.id);
}

class RemoveFollowerLocal extends CreateTaskEvent {
  final String id;
  const RemoveFollowerLocal(this.id);
}

class UpdatedStatusEvent extends CreateTaskEvent {
  final String taskId;
  final String status;
  const UpdatedStatusEvent(this.taskId, this.status);
}
