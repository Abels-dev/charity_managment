import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';

abstract class CharityRepository {
  Future<List<CharityPublicProfile>> fetchCharities();

  Future<CharityPublicProfile?> getCharityById(String charityId);

  Future<CharityPublicProfile?> getMyProfile();
}
