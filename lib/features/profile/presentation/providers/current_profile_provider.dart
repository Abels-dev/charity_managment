import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/presentation/providers/profile_repository_provider.dart';

final currentProfileProvider = FutureProvider<ProfileData>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCurrentUserProfile();
});
