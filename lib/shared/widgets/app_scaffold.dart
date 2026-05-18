import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/shared/widgets/notification_bell_action.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.showNotificationAction = true,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool showNotificationAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mergedActions = <Widget>[
      if (actions != null) ...actions!,
      if (showNotificationAction) const NotificationBellAction(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: mergedActions.isEmpty ? null : mergedActions,
      ),
      drawer: drawer,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: body,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
