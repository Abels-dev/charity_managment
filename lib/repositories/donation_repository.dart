import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';

abstract class DonationRepository {
  Future<Donation> createDonation(Donation donation);

  Future<List<Donation>> getDonationHistory(String donorId);

  Future<List<Donation>> getDonationsByCampaignIds(Set<String> campaignIds);

  Future<Donation?> getDonationById(String donationId);

  Future<Donation> setDonationAnonymous({
    required String donationId,
    required bool isAnonymous,
  });

  Future<DonationReceipt> generateReceipt(Donation donation);

  Future<DonationReceipt?> getReceiptByDonationId(String donationId);
}
