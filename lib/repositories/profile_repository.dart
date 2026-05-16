import 'package:charity_managment/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchMyProfile();
}
