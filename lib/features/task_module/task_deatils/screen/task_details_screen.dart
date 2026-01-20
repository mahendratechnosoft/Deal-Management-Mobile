import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_event.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_state.dart';
import 'details_cart.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({super.key});

  @override
  State createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskId = GoRouterState.of(context).extra as String;
      context.read<CreateTaskBloc>().add(GetTaskEvent(taskId: taskId));
      context.read<CreateTaskBloc>().add(LoadAssigneesEvent());
      context.read<CreateTaskBloc>().add(TimerStatusEvent(taskId: taskId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Task Details'),
      body: BlocBuilder<CreateTaskBloc, CreateTaskState>(
        builder: (context, state) {
          if (state.isLoading || state.getTaskModel == null) {
            return SkeletonCard(
              isLoading: true,
              itemCount: 10,
              borderRadius: 16,
              padding: EdgeInsets.symmetric(vertical: 20),
            );
          }

          return detailsWidget(context, state);
          
        },
      ),
    );
  }
}
