import 'package:go_router/go_router.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/presentation/screens/login_screen.dart';
import 'package:xpertbiz/features/auth/presentation/screens/splash_screen.dart';
import 'package:xpertbiz/features/customers/presentation/customers_screen.dart';
import 'package:xpertbiz/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:xpertbiz/features/invoice/presentation/invoice_screen.dart';
import 'package:xpertbiz/features/settings/presentation/settings_screen.dart';
import 'package:xpertbiz/features/task/edit_task/presentation/task_edit_screen.dart';
import 'package:xpertbiz/features/task/presentation/task_screen.dart';

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
          return DashboardScreen();
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
        path: AppRouteName.customers,
        name: 'customers',
        builder: (context, state) {
          return CustomersScreen();
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
    ],
  );
}
