import 'package:flutter/material.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CommonAppBar(title: 'Notifications'));
  }
}
