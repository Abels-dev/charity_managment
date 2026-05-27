import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/charity_dashboard/data/mock_dashboard_repository.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final campaigns = ref.watch(campaignRepositoryProvider);
  final donations = ref.watch(donationRepositoryProvider);
  return MockDashboardRepository(
    campaignRepository: campaigns,
    donationRepository: donations,
  );
});
