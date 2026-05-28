import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';
import 'package:charity_managment/repositories/donation_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_donations.dart';

class MockDonationRepository implements DonationRepository {
  static final List<Donation> _donations = List<Donation>.from(mockDonations);
  static final Map<String, DonationReceipt> _receipts = _seedReceipts();

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
  Future<List<Donation>> getDonationsByCampaignIds(Set<String> campaignIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));

    final results = _donations
        .where((donation) => campaignIds.contains(donation.campaignId))
        .toList(growable: false);

    results.sort((a, b) => b.donatedAt.compareTo(a.donatedAt));
    return results;
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

  @override
  Future<Donation> setDonationAnonymous({
    required String donationId,
    required bool isAnonymous,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final index = _donations.indexWhere((donation) => donation.id == donationId);
    if (index < 0) {
      throw StateError('Donation not found.');
    }

    final updated = Donation(
      id: _donations[index].id,
      donorId: _donations[index].donorId,
      campaignId: _donations[index].campaignId,
      amount: _donations[index].amount,
      isAnonymous: isAnonymous,
      transactionId: _donations[index].transactionId,
      status: _donations[index].status,
      donatedAt: _donations[index].donatedAt,
      message: _donations[index].message,
    );

    _donations[index] = updated;
    return updated;
  }

  @override
  Future<DonationReceipt> generateReceipt(Donation donation) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));

    final existing = _receipts[donation.id];
    if (existing != null) {
      return existing;
    }

    final receipt = DonationReceipt(
      id: 'rct_${donation.id}',
      donationId: donation.id,
      reference: _referenceFor(donation.id),
      issuedAt: DateTime.now(),
    );
    _receipts[donation.id] = receipt;
    return receipt;
  }

  @override
  Future<DonationReceipt?> getReceiptByDonationId(String donationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _receipts[donationId];
  }

  static Map<String, DonationReceipt> _seedReceipts() {
    final receipts = <String, DonationReceipt>{};
    for (final donation in _donations) {
      receipts[donation.id] = DonationReceipt(
        id: 'rct_${donation.id}',
        donationId: donation.id,
        reference: _referenceFor(donation.id),
        issuedAt: donation.donatedAt,
      );
    }
    return receipts;
  }

  static String _referenceFor(String donationId) {
    return 'RCT-${donationId.toUpperCase()}';
  }
}
