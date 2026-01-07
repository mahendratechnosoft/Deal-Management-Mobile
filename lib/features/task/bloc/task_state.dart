import 'package:equatable/equatable.dart';
import 'package:xpertbiz/features/task/data/model/task_list_model.dart';

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

/// FILTER MODEL
class TaskFilter extends Equatable {
  final String search;
  final String status;
  final String priority;

  const TaskFilter({
    this.search = '',
    this.status = 'All',
    this.priority = 'All',
  });

  TaskFilter copyWith({
    String? search,
    String? status,
    String? priority,
  }) {
    return TaskFilter(
      search: search ?? this.search,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [search, status, priority];
}

/// SUCCESS WITH PAGINATION
class TaskListSuccess extends TaskListState {
  final List<TaskList> tasks;
  final TaskFilter filter;
  final int page;
  final bool hasReachedMax;

  const TaskListSuccess({
    required this.tasks,
    required this.filter,
    required this.page,
    required this.hasReachedMax,
  });

  List<TaskList> get filteredTasks {
    return tasks.where((task) {
      final titleMatch =
          task.subject.toLowerCase().contains(filter.search.toLowerCase());
      final statusMatch =
          filter.status == 'All' || task.status == filter.status;
      final priorityMatch =
          filter.priority == 'All' || task.priority == filter.priority;
      return titleMatch && statusMatch && priorityMatch;
    }).toList();
  }

  TaskListSuccess copyWith({
    List<TaskList>? tasks,
    TaskFilter? filter,
    int? page,
    bool? hasReachedMax,
  }) {
    return TaskListSuccess(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [tasks, filter, page, hasReachedMax];
}

class TaskFailure extends TaskListState {
  final String message;
  const TaskFailure(this.message);

  @override
  List<Object?> get props => [message];
}
