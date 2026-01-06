import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final user = AuthLocalStorage.getUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthLocalStorage.clear();
              context.go(AppRouteName.login);
            },
          ),
        ],
        title: Text(
            'Hello ${user?.loginEmail.split('@').first.replaceAll(RegExp(r'\d+'), '')}'),
      ),
      body: const Center(
        child: Text('Welcome to the Dashboard!'),
      ),
    );
  }
}
