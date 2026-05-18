import 'package:charity_managment/models/donation.dart';

abstract class DonationRepository {
  Future<Donation> createDonation(Donation donation);

  Future<List<Donation>> getDonationHistory(String donorId);

  Future<Donation?> getDonationById(String donationId);
}
