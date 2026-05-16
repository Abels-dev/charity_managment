import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/repositories/donation_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_donations.dart';

class MockDonationRepository implements DonationRepository {
  @override
  Future<List<Donation>> fetchDonations() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return mockDonations;
  }
}
