import 'package:flutter/material.dart';

import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

class CharityDashboardScreen extends StatelessWidget {
  const CharityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Charity Dashboard',
      drawer: AppNavigationDrawer(),
      body: Center(
        child: Text('Charity dashboard scaffold is ready.'),
      ),
    );
  }
}
