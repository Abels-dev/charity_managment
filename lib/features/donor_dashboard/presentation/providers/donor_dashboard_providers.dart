import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/features/donor_dashboard/domain/donor_dashboard_summary.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/user_role.dart';

final donorDashboardSummaryProvider = FutureProvider<DonorDashboardSummary>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null || user.role != UserRole.donor) {
    return const DonorDashboardSummary(
      totalDonated: 0,
      campaignsSupported: 0,
      monthlyTotal: 0,
      activeFollowed: 0,
      anonymousCount: 0,
    );
  }

  final donationRepository = ref.watch(donationRepositoryProvider);
  final campaignRepository = ref.watch(campaignRepositoryProvider);

  final donations = await donationRepository.getDonationHistory(user.id);
  final completed = donations
      .where((donation) => donation.status == DonationStatus.completed)
      .toList(growable: false);

  final now = DateTime.now();
  final monthlyTotal = completed
      .where((donation) =>
          donation.donatedAt.year == now.year &&
          donation.donatedAt.month == now.month)
      .fold<double>(0, (sum, donation) => sum + donation.amount);

  final totalDonated =
      completed.fold<double>(0, (sum, donation) => sum + donation.amount);
  final campaignsSupported =
      completed.map((donation) => donation.campaignId).toSet().length;
  final anonymousCount =
      completed.where((donation) => donation.isAnonymous).length;

  final followedCampaigns = await campaignRepository.getFollowedCampaigns();
  final activeFollowed = followedCampaigns
      .where((campaign) => campaign.status == CampaignStatus.active)
      .length;

  return DonorDashboardSummary(
    totalDonated: totalDonated,
    campaignsSupported: campaignsSupported,
    monthlyTotal: monthlyTotal,
    activeFollowed: activeFollowed,
    anonymousCount: anonymousCount,
  );
});

final donorRecentDonationsProvider = FutureProvider<List<Donation>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null || user.role != UserRole.donor) {
    return const <Donation>[];
  }

  final donationRepository = ref.watch(donationRepositoryProvider);
  final donations = await donationRepository.getDonationHistory(user.id);
  return donations.take(4).toList(growable: false);
});

final donorFollowedPreviewProvider = FutureProvider<List<Campaign>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null || user.role != UserRole.donor) {
    return const <Campaign>[];
  }

  final repository = ref.watch(campaignRepositoryProvider);
  final campaigns = await repository.getFollowedCampaigns();
  return campaigns.take(3).toList(growable: false);
});
