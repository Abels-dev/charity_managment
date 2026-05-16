import 'package:flutter/material.dart';

import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Profile',
      drawer: AppNavigationDrawer(),
      body: Center(
        child: Text('Profile module scaffold is ready.'),
      ),
    );
  }
}
