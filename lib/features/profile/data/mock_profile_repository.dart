import 'package:charity_managment/features/profile/data/local/profile_local_storage.dart';
import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/charity_profile.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository(
    this._localStorage, {
    required this.role,
    required ProfileData seedProfile,
  }) : _seedProfile = seedProfile;

  final ProfileLocalStorage _localStorage;
  final ProfileRole role;
  final ProfileData _seedProfile;

  @override
  Future<ProfileData> getCurrentUserProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final stored = await _localStorage.readProfile(role);
    if (stored != null) return stored;

    await _localStorage.saveProfile(role, _seedProfile);
    return _seedProfile;
  }

  @override
  Future<ProfileData> updateUserProfile(UserProfileUpdateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final current = await getCurrentUserProfile();
    final updatedUser = current.user.copyWith(
      name: input.name,
      phone: input.phone,
      bio: input.bio,
      updatedAt: DateTime.now(),
    );

    final updatedProfile = current.copyWith(user: updatedUser);
    await _localStorage.saveProfile(role, updatedProfile);
    return updatedProfile;
  }

  @override
  Future<ProfileData> updateCharityProfile(
    CharityProfileUpdateInput input,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final current = await getCurrentUserProfile();
    final existing = current.charityProfile;
    if (existing == null) {
      throw StateError('Charity profile not found for this account.');
    }

    final updatedCharity = existing.copyWith(
      organizationName: input.organizationName,
      description: input.description,
      phone: input.phone,
      website: input.website,
      address: input.address,
      socialFacebook: input.socialFacebook,
      socialTelegram: input.socialTelegram,
      socialInstagram: input.socialInstagram,
      socialTwitter: input.socialTwitter,
      socialYoutube: input.socialYoutube,
      socialTiktok: input.socialTiktok,
    );

    final updatedUser = current.user.copyWith(
      name: input.organizationName,
      updatedAt: DateTime.now(),
    );

    final updatedProfile = current.copyWith(
      user: updatedUser,
      charityProfile: updatedCharity,
    );
    await _localStorage.saveProfile(role, updatedProfile);
    return updatedProfile;
  }

  @override
  Future<ProfileData> createCharityProfile({
    required String organizationName,
    required String description,
    required String documentPath,
    String? logoPath,
    String? phone,
    String? address,
    String? website,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final current = await getCurrentUserProfile();
    final charityProfile = current.charityProfile?.copyWith(
          organizationName: organizationName,
          description: description,
          documentUrl: documentPath,
          phone: phone,
          address: address,
          website: website,
          verifiedAt: null,
        ) ??
        CharityProfile(
          organizationName: organizationName,
          description: description,
          documentUrl: documentPath,
          phone: phone,
          address: address,
          website: website,
          verifiedAt: null,
        );

    final updatedProfile = current.copyWith(charityProfile: charityProfile);
    await _localStorage.saveProfile(role, updatedProfile);
    return updatedProfile;
  }
}
