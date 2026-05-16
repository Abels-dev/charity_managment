import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';

abstract class ProfileRepository {
  Future<ProfileData> getCurrentUserProfile();

  Future<ProfileData> updateUserProfile(UserProfileUpdateInput input);

  Future<ProfileData> updateCharityProfile(CharityProfileUpdateInput input);
}
