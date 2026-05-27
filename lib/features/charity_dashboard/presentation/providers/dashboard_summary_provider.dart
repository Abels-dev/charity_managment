import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/charity_dashboard/domain/dashboard_summary.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/providers/dashboard_repository_provider.dart';
import 'package:charity_managment/models/user_role.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null) {
    throw StateError('You must be signed in to view the dashboard.');
  }

  if (user.role != UserRole.charityOrganization) {
    return DashboardSummary.empty;
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardSummary(charityId: user.id);
});
