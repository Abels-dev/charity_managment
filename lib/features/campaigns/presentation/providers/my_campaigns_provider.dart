import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_repository_provider.dart';
import 'package:charity_managment/models/campaign.dart';

final myCampaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];

  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getMyCampaigns(user.id);
});
