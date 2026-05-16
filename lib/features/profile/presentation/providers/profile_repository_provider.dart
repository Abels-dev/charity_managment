import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/profile/data/local/profile_local_storage.dart';
import 'package:charity_managment/features/profile/data/mock_profile_data.dart';
import 'package:charity_managment/features/profile/data/mock_profile_repository.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/repositories/profile_repository.dart';

final profileLocalStorageProvider = Provider<ProfileLocalStorage>((ref) {
  return ProfileLocalStorage();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final auth = ref.watch(authControllerProvider);
  final localStorage = ref.watch(profileLocalStorageProvider);

  final role = _mapRole(auth.user?.role);
  final seedProfile = _seedForRole(role);

  return MockProfileRepository(
    localStorage,
    role: role,
    seedProfile: seedProfile,
  );
});

ProfileRole _mapRole(UserRole? role) {
  if (role == UserRole.charityOrganization) {
    return ProfileRole.charity;
  }
  return ProfileRole.donor;
}

ProfileData _seedForRole(ProfileRole role) {
  if (role == ProfileRole.charity) {
    return mockCharityProfile;
  }
  return mockDonorProfile;
}
