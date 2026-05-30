import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';
import 'package:charity_managment/features/donations/domain/donation_checkout_session.dart';

abstract class DonationRepository {
  Future<Donation> createDonation(Donation donation);

  Future<Donation> createDirectDonation(
    Donation donation, {
    String? donorName,
    String? donorEmail,
  });

  Future<DonationCheckoutSession> createDonationCheckout(
    Donation donation, {
    String? donorName,
    String? donorEmail,
    String? returnUrl,
  });

  Future<List<Donation>> getDonationHistory(String donorId);

  Future<List<Donation>> getDonationsByCampaignIds(Set<String> campaignIds);

  Future<Donation?> getDonationById(String donationId);

  Future<Donation> setDonationAnonymous({
    required String donationId,
    required bool isAnonymous,
  });

  Future<Donation?> getDonationByTransactionRef(String txRef);

  Future<DonationReceipt> generateReceipt(Donation donation);

  Future<DonationReceipt?> getReceiptByDonationId(String donationId);
}
