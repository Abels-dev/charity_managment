import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/repositories/profile_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_users.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> fetchMyProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return donorUser;
  }
}
