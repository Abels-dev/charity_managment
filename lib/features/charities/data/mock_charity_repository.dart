import 'package:charity_managment/features/charities/data/mock/mock_charities_data.dart';
import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/repositories/charity_repository.dart';

class MockCharityRepository implements CharityRepository {
  static final List<CharityPublicProfile> _charities =
      List<CharityPublicProfile>.from(seedCharities);

  @override
  Future<List<CharityPublicProfile>> fetchCharities() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<CharityPublicProfile>.from(_charities);
  }

  @override
  Future<CharityPublicProfile?> getCharityById(String charityId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (final charity in _charities) {
      if (charity.id == charityId) {
        return charity;
      }
    }
    return null;
  }

  @override
  Future<CharityPublicProfile?> getMyProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _charities.isEmpty ? null : _charities.first;
  }
}
