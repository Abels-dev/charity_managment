import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/user_role.dart';

final donationHistoryProvider = FutureProvider<List<Donation>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null) {
    throw StateError('You must be signed in to view donations.');
  }

  if (user.role != UserRole.donor) {
    return const <Donation>[];
  }

  final repository = ref.watch(donationRepositoryProvider);
  return repository.getDonationHistory(user.id);
});
