import 'package:go_router/go_router.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/presentation/screens/login_screen.dart';
import 'package:xpertbiz/features/auth/presentation/screens/splash_screen.dart';
import 'package:xpertbiz/features/timesheet/presentation/emp_list_screen.dart';
import 'package:xpertbiz/features/Lead/presentation/screens/lead_screen.dart';
import 'package:xpertbiz/features/invoice/presentation/invoice_screen.dart';
import 'package:xpertbiz/features/settings/presentation/settings_screen.dart';
import 'package:xpertbiz/features/task_module/create_task/screens/create_task_screen.dart';
import 'package:xpertbiz/features/task_module/edit_task/presentation/task_edit_screen.dart';
import 'package:xpertbiz/features/task_module/task_deatils/screen/task_details_screen.dart';
import 'package:xpertbiz/features/task_module/task/presentation/task_screen.dart';
import 'package:xpertbiz/features/timesheet/presentation/timesheet_screen.dart';

import 'Lead/presentation/screens/all_lead_scren.dart';
import 'timesheet/data/model/emp_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRouteName.splash,
    routes: [
      GoRoute(
        path: AppRouteName.splash,
        name: 'home',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: AppRouteName.login,
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: AppRouteName.dashboard,
        name: 'dashboard',
        builder: (context, state) {
          return LeadScreen();
        },
      ),
      GoRoute(
        path: AppRouteName.task,
        name: 'task',
        builder: (context, state) {
          return TaskScreen();
        },
      ),
      GoRoute(
        path: AppRouteName.invoice,
        name: 'invoice',
        builder: (context, state) {
          return InvoiceScreen();
        },
      ),
      GoRoute(
        path: AppRouteName.timesheet,
        name: 'timesheets',
        builder: (context, state) {
          return EmployeeListScreen();
        },
      ),
      GoRoute(
        path: AppRouteName.settings,
        name: 'settings',
        builder: (context, state) {
          return SettingsScreen();
        },
      ),
      GoRoute(
        path: AppRouteName.editTask,
        name: 'task edit',
        builder: (context, state) {
          return EditTask();
        },
      ),
      GoRoute(
        path: AppRouteName.createTask,
        name: 'create task',
        builder: (context, state) {
          return CreateTask();
        },
      ),
      GoRoute(
        path: AppRouteName.taskDetails,
        name: 'task details',
        builder: (context, state) {
          return TaskDetails();
        },
      ),
      GoRoute(
        path: AppRouteName.attendance,
        name: 'attendance',
        builder: (context, state) {
          return AttendanceCalendarScreen(
            employee: state.extra as Employee,
          );
        },
      ),
      GoRoute(
        path: AppRouteName.allLead,
        name: 'all Lead',
        builder: (context, state) {
          return AllLeadScreen();
        },
      ),
    ],
  );
}
