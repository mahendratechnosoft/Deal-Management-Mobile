import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// FETCH TASKS (pagination)
class FetchTasks extends TaskEvent {
  final bool isLoadMore;

  const FetchTasks({this.isLoadMore = false});

  @override
  List<Object?> get props => [isLoadMore];
}

/// SEARCH
class UpdateSearch extends TaskEvent {
  final String value;
  const UpdateSearch(this.value);

  @override
  List<Object?> get props => [value];
}

/// STATUS
class UpdateStatus extends TaskEvent {
  final String value;
  const UpdateStatus(this.value);

  @override
  List<Object?> get props => [value];
}

/// PRIORITY
class UpdatePriority extends TaskEvent {
  final String value;
  const UpdatePriority(this.value);

  @override
  List<Object?> get props => [value];
}
