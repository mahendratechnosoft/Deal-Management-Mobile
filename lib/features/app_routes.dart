import 'package:go_router/go_router.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/presentation/screens/login_screen.dart';
import 'package:xpertbiz/features/auth/presentation/screens/splash_screen.dart';
import 'package:xpertbiz/features/dashboard/presentation/screens/dashboard_screen.dart';

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
    ],
  );
}
