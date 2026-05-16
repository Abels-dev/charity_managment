import 'package:flutter/material.dart';

import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Donations',
      drawer: AppNavigationDrawer(),
      body: Center(
        child: Text('Donations module scaffold is ready.'),
      ),
    );
  }
}
