import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTransition {
  static CustomTransitionPage slide({
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: duration,
      child: child,
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage fade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 300),
      child: child,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
