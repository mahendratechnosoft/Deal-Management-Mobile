import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_bloc.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_event.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_state.dart';
import 'package:xpertbiz/features/task_module/task/widget/delete_dailog.dart';
import 'package:xpertbiz/features/task_module/task/widget/task_filter.dart';
import 'package:xpertbiz/features/task_module/task/widget/task_table/task_card.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgtes/app_snackbar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _controller = ScrollController();
  LoginResponse? user;
  bool? access;
  bool? delete;

  @override
  void initState() {
    super.initState();
    user = AuthLocalStorage.getUser();
    access = user?.moduleAccess.taskCreate;
    delete = user?.moduleAccess.taskDelete;
    log('check access : $access');
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        context.read<TaskBloc>().add(const FetchTasks(isLoadMore: true));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch tasks once after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(const FetchTasks(isLoadMore: false));
    });
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<TaskBloc>().add(const FetchTasks(isLoadMore: false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskListState>(
      listener: (context, state) {
        /// ✅ SUCCESS SNACKBAR + REFRESH
        if (state is DeleteTaskState) {
          AppSnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.success,
          );
          context.read<TaskBloc>().add(const FetchTasks(isLoadMore: false));
        }
        if (state is TaskFailure) {
          AppSnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(237, 248, 250, 252),
        appBar: CommonAppBar(title: 'Task'),
        floatingActionButton: access == false
            ? SizedBox.shrink()
            : FloatingActionButton(
                backgroundColor: AppColors.primaryDark,
                onPressed: () async {
                  final result = await context.push(AppRouteName.createTask);
                  if (result == true && mounted) {
                    context
                        .read<TaskBloc>()
                        .add(const FetchTasks(isLoadMore: false));
                  }
                },
                child: const Icon(Icons.add, color: AppColors.background),
              ),
        body: Column(
          children: [
            BlocBuilder<TaskBloc, TaskListState>(
              builder: (context, state) {
                if (state is TaskListSuccess) {
                  return TaskFilterBar(
                    filter: state.filter,
                    onSearch: (v) =>
                        context.read<TaskBloc>().add(UpdateSearch(v)),
                    onStatus: (v) =>
                        context.read<TaskBloc>().add(UpdateStatus(v)),
                    onPriority: (v) =>
                        context.read<TaskBloc>().add(UpdatePriority(v)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskListState>(
                builder: (context, state) {
                  if (state is TaskListLoading) {
                    return SkeletonCard(
                      isLoading: true,
                      itemCount: 10,
                      borderRadius: 16,
                    );
                  }

                  if (state is TaskListSuccess) {
                    if (state.tasks.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => _onRefresh(context),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text("No tasks found")),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => _onRefresh(context),
                      child: ListView.builder(
                        controller: _controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = state.filteredTasks[index];
                          final assigneeName = task.assignedEmployees.isNotEmpty
                              ? task.assignedEmployees.first.name
                              : 'Unassigned';

                          log('Ganesh => ${state.filteredTasks.length}');

                          return InkWell(
                            onTap: () async {
                              final res = await context.push(
                                  AppRouteName.taskDetails,
                                  extra: task.taskId);
                              if (res == true && mounted) {
                                context
                                    .read<TaskBloc>()
                                    .add(const FetchTasks(isLoadMore: false));
                              }
                            },
                            child: TaskCard(
                              enable: delete,
                              id: '$index',
                              title: task.subject,
                              status: task.status.toReadableStatus(),
                              priority: task.priority,
                              startDate: DateFormat('dd MMM yyyy')
                                  .format(task.startDate),
                              endDate: DateFormat('dd MMM yyyy')
                                  .format(task.endDate),
                              assignee: assigneeName,
                              onEdit: () async {
                                final result = await context.push(
                                  AppRouteName.editTask,
                                  extra: task.taskId,
                                );
                                if (result == true && mounted) {
                                  context
                                      .read<TaskBloc>()
                                      .add(const FetchTasks(isLoadMore: false));
                                }
                              },
                              onDelete: () {
                                log('task Id : ${task.taskId}');
                                showDeleteDialog(context, task.taskId);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is TaskFailure) {
                    //_onRefresh(context);
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    ));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StatusFormatter on String {
  String toReadableStatus() {
    return split('_')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
