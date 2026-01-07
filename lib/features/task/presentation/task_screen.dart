import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/task/bloc/task_bloc.dart';
import 'package:xpertbiz/features/task/bloc/task_event.dart';
import 'package:xpertbiz/features/task/bloc/task_state.dart';
import 'package:xpertbiz/features/task/widget/delete_dailog.dart';
import 'package:xpertbiz/features/task/widget/task_filter.dart';
import 'package:xpertbiz/features/task/widget/task_table/task_card.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        context.read<TaskBloc>().add(const FetchTasks(isLoadMore: true));
      }
    });
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<TaskBloc>().add(const FetchTasks(isLoadMore: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(237, 248, 250, 252),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        iconTheme: IconThemeData(color: AppColors.background),
        title: Text(
          "Tasks",
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
            fontSize: Responsive.sp(20),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        onPressed: () {},
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TaskListSuccess) {
                  if (state.filteredTasks.isEmpty) {
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
                        return TaskCard(
                          id: '$index',
                          title: task.subject,
                          status: task.status.toReadableStatus(),
                          priority: task.priority,
                          startDate:
                              DateFormat('dd MMM yyyy').format(task.startDate),
                          endDate:
                              DateFormat('dd MMM yyyy').format(task.endDate),
                          assignee: 'Admin',
                          onEdit: () {},
                          onDelete: () {
                            showDeleteDialog(context, "$index");
                          },
                        );
                      },
                    ),
                  );
                }

                if (state is TaskFailure) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
