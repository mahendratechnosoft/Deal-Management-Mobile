import 'dart:developer';

import 'package:go_router/go_router.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/presentation/screens/all_lead_details_screen.dart';
import 'package:xpertbiz/features/Lead/presentation/screens/create_lead_screen.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/presentation/screens/login_screen.dart';
import 'package:xpertbiz/features/auth/presentation/screens/splash_screen.dart';
import 'package:xpertbiz/features/Lead/presentation/screens/lead_screen.dart';
import 'package:xpertbiz/features/Lead/presentation/screens/all_lead_scren.dart';
import 'package:xpertbiz/features/customers/presentation/customer_screen.dart';
import 'package:xpertbiz/features/settings/presentation/settings_screen.dart';
import 'package:xpertbiz/features/task_module/task/presentation/task_screen.dart';
import 'package:xpertbiz/features/task_module/create_task/screens/create_task_screen.dart';
import 'package:xpertbiz/features/task_module/edit_task/presentation/task_edit_screen.dart';
import 'package:xpertbiz/features/task_module/task_deatils/screen/task_details_screen.dart';
import 'package:xpertbiz/features/timesheet/presentation/emp_list_screen.dart';
import 'package:xpertbiz/features/timesheet/presentation/timesheet_screen.dart';
import 'package:xpertbiz/features/timesheet/data/model/emp_model.dart';
import 'app_transition.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRouteName.splash,
    routes: [
      /// SPLASH
      GoRoute(
        path: AppRouteName.splash,
        pageBuilder: (context, state) => AppTransition.fade(
          state: state,
          child: const SplashScreen(),
        ),
      ),

      /// LOGIN
      GoRoute(
        path: AppRouteName.login,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const LoginScreen(),
        ),
      ),

      /// DASHBOARD / LEADS
      GoRoute(
        path: AppRouteName.dashboard,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const LeadScreen(),
        ),
      ),

      /// ALL LEADS (with query param)
      GoRoute(
        path: AppRouteName.allLead,
        pageBuilder: (context, state) {
          final status = state.uri.queryParameters['status'];
          return AppTransition.slide(
            state: state,
            child: AllLeadScreen(status: status),
          );
        },
      ),

      /// TASK
      GoRoute(
        path: AppRouteName.task,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const TaskScreen(),
        ),
      ),

      /// CREATE TASK
      GoRoute(
        path: AppRouteName.createTask,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const CreateTask(),
        ),
      ),

      /// EDIT TASK
      GoRoute(
        path: AppRouteName.editTask,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const EditTask(),
        ),
      ),

      /// TASK DETAILS
      GoRoute(
        path: AppRouteName.taskDetails,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const TaskDetails(),
        ),
      ),

      /// INVOICE
      GoRoute(
        path: AppRouteName.customers,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const CustomerScreen(),
        ),
      ),
      GoRoute(
        path: AppRouteName.settings,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRouteName.timesheet,
        pageBuilder: (context, state) => AppTransition.slide(
          state: state,
          child: const EmployeeListScreen(),
        ),
      ),
      GoRoute(
        path: AppRouteName.attendance,
        pageBuilder: (context, state) {
          final employee = state.extra as Employee;
          return AppTransition.slide(
            state: state,
            child: AttendanceCalendarScreen(employee: employee),
          );
        },
      ),

      GoRoute(
        path: AppRouteName.leadDetails,
        name: AppRouteName.leadDetails,
        builder: (context, state) {
          final lead = state.extra as LeadModel;

          return AllLeadDetailsScreen(lead: lead);
        },
      ),
      GoRoute(
        path: AppRouteName.createLead,
        pageBuilder: (context, state) {
          final bool edit = state.extra as bool? ?? true;
          log('ROUTE extra = ${state.extra}'); // 👈 debug
          return AppTransition.slide(
            state: state,
            child: CreateLeadScreen(edit: edit),
          );
        },
      ),
    ],
  );
}
