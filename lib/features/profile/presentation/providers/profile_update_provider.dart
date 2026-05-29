import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/features/profile/presentation/providers/current_profile_provider.dart';
import 'package:charity_managment/features/profile/presentation/providers/profile_repository_provider.dart';

class ProfileUpdateController extends StateNotifier<AsyncValue<ProfileData?>> {
  ProfileUpdateController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<ProfileData?> updateUserProfile(UserProfileUpdateInput input) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(profileRepositoryProvider);
      final updated = await repository.updateUserProfile(input);
      _ref.invalidate(currentProfileProvider);
      state = AsyncValue.data(updated);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<ProfileData?> updateCharityProfile(
    CharityProfileUpdateInput input,
  ) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(profileRepositoryProvider);
      final updated = await repository.updateCharityProfile(input);
      _ref.invalidate(currentProfileProvider);
      state = AsyncValue.data(updated);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<ProfileData?> createCharityProfile({
    required String organizationName,
    required String description,
    required String documentPath,
    String? logoPath,
    String? phone,
    String? address,
    String? website,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(profileRepositoryProvider);
      final updated = await repository.createCharityProfile(
        organizationName: organizationName,
        description: description,
        documentPath: documentPath,
        logoPath: logoPath,
        phone: phone,
        address: address,
        website: website,
      );
      _ref.invalidate(currentProfileProvider);
      state = AsyncValue.data(updated);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final profileUpdateProvider =
    StateNotifierProvider<ProfileUpdateController, AsyncValue<ProfileData?>>(
  (ref) => ProfileUpdateController(ref),
);
