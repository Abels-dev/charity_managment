import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/charity_dashboard/domain/donation_activity.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/providers/dashboard_repository_provider.dart';
import 'package:charity_managment/models/user_role.dart';

final recentDonationsProvider = FutureProvider<List<DonationActivity>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null) {
    throw StateError('You must be signed in to view the dashboard.');
  }

  if (user.role != UserRole.charityOrganization) {
    return const <DonationActivity>[];
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentDonations(charityId: user.id);
});
