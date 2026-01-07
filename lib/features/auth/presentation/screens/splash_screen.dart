import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/images/app_images.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/app_route_name.dart';
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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Responsive.init(context);
      if (AuthLocalStorage.isLoggedIn()) {
        context.go(AppRouteName.dashboard);
      } else {
        context.go(AppRouteName.login);
      }
    });
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
              width: Responsive.sp(150),
              height: Responsive.sp(150),
            ),
          ),
        ),
      ),
    );
  }
}
