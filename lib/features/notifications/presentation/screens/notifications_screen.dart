import 'package:flutter/material.dart';

import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Notifications',
      drawer: AppNavigationDrawer(),
      body: Center(
        child: Text('Notifications module scaffold is ready.'),
      ),
    );
  }
}
