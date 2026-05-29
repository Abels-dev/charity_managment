import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/profile/data/api_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/profile/data/local/profile_local_storage.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/repositories/profile_repository.dart';

final profileLocalStorageProvider = Provider<ProfileLocalStorage>((ref) {
  return ProfileLocalStorage();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final auth = ref.watch(authControllerProvider);
  final localStorage = ref.watch(profileLocalStorageProvider);
  final dio = ref.watch(dioProvider);

  final role = _mapRole(auth.user?.role);

  return ApiProfileRepository(
    dio,
    localStorage,
    role: role,
  );
});

ProfileRole _mapRole(UserRole? role) {
  if (role == UserRole.charityOrganization) {
    return ProfileRole.charity;
  }
  return ProfileRole.donor;
}
