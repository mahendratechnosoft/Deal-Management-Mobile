import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/images/app_images.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/app_update/presentation/widgets/app_update_dialog.dart';
import 'package:xpertbiz/features/app_update/services/app_update_service.dart';
import '../../data/locale_data/hive_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _checkUpdateAndNavigate();
  }

  Future<void> _checkUpdateAndNavigate() async {
    // Show splash animation for at least 1.8 seconds
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Responsive.init(context);

    // Check for App Updates (Major vs Minor)
    try {
      final updateInfo = await AppUpdateService.checkForUpdate();
      if (mounted && updateInfo != null && updateInfo.hasUpdate) {
        if (updateInfo.isMajor) {
          // Major update: blocks entry completely until user updates
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AppUpdateDialog(updateInfo: updateInfo),
          );
          return;
        } else if (updateInfo.isMinor) {
          // Minor update: has skip/later option, if skipped continue
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AppUpdateDialog(updateInfo: updateInfo),
          );
        }
      }
    } catch (_) {
      // Continue gracefully if network error
    }

    if (!mounted) return;
    if (AuthLocalStorage.isLoggedIn()) {
      final initialRoute = AuthLocalStorage.getInitialRoute();
      context.go(initialRoute);
    } else {
      context.go(AppRouteName.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset(
              AppImages.logo,
              width: Responsive.sp(200),
              height: Responsive.sp(200),
            ),
          ),
        ),
      ),
    );
  }
}
