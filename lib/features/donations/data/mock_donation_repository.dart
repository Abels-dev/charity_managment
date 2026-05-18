import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/repositories/donation_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_donations.dart';

class MockDonationRepository implements DonationRepository {
  static final List<Donation> _donations = List<Donation>.from(mockDonations);

  @override
  Future<Donation> createDonation(Donation donation) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _donations.insert(0, donation);
    return donation;
  }

  @override
  Future<List<Donation>> getDonationHistory(String donorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));

    final history = _donations
        .where((donation) => donation.donorId == donorId)
        .toList(growable: false);

    history.sort((a, b) => b.donatedAt.compareTo(a.donatedAt));
    return history;
  }

  @override
  Future<Donation?> getDonationById(String donationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    for (final donation in _donations) {
      if (donation.id == donationId) {
        return donation;
      }
    }

    return null;
  }
}
