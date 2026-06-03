import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/models/donation_receipt.dart';
import 'package:charity_managment/features/donations/domain/donation_checkout_session.dart';
import 'package:charity_managment/repositories/donation_repository.dart';
import 'package:dio/dio.dart';

class ApiDonationRepository implements DonationRepository {
  ApiDonationRepository(this._dio);

  final Dio _dio;

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Donation _mapDonation(Map<String, dynamic> json) {
    final donorId = json['donorId'] ?? json['donor']?['id'];
    final campaignId = json['campaignId'] ?? json['campaign']?['id'];
    final transactionId = json['transactionId'] ?? json['txRef'] ?? json['transactionReference'] ?? json['id'];
    final donatedAtRaw = json['donatedAt'] ?? json['createdAt'] ?? json['updatedAt'];

    return Donation(
      id: json['id'].toString(),
      donorId: donorId?.toString() ?? '',
      campaignId: campaignId?.toString() ?? '',
      amount: _asDouble(json['amount']),
      isAnonymous: json['isAnonymous'] ?? false,
      transactionId: transactionId?.toString() ?? json['id'].toString(),
      status: _mapStatus(json['status']),
      donatedAt: donatedAtRaw != null ? DateTime.parse(donatedAtRaw.toString()) : DateTime.now(),
      message: json['message']?.toString(),
      guestName: json['guestName']?.toString(),
      guestEmail: json['guestEmail']?.toString(),
    );
  }

  DonationStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return DonationStatus.pending;
      case 'FAILED':
        return DonationStatus.failed;
      case 'COMPLETED':
      default:
        return DonationStatus.completed;
    }
  }

  @override
  Future<DonationCheckoutSession> createDonationCheckout(
    Donation donation, {
    String? donorName,
    String? donorEmail,
    String? returnUrl,
  }) async {
    return createDonationCheckoutWithPayer(
      donation,
      donorName: donorName,
      donorEmail: donorEmail,
      returnUrl: returnUrl,
    );
  }

  Future<DonationCheckoutSession> createDonationCheckoutWithPayer(
    Donation donation, {
    String? donorName,
    String? donorEmail,
    String? returnUrl,
  }) async {
    final payload = <String, dynamic>{
      'amount': donation.amount,
      'isAnonymous': donation.isAnonymous,
      'message': donation.message,
      if (donorName != null) 'guestName': donorName,
      if (donorEmail != null) 'guestEmail': donorEmail,
      if (returnUrl != null) 'returnUrl': returnUrl,
    };

    final response = await _dio.post('/api/campaign/${donation.campaignId}/donate', data: payload);

    final data = _asMap(response.data['data']);
    final donationData = _asMap(data['donation']);
    final chapaData = _asMap(data['chapa']);

    return DonationCheckoutSession(
      donationId: donationData['id']?.toString() ?? donation.id,
      txRef: donationData['transactionId']?.toString() ?? '',
      checkoutUrl: chapaData['checkoutUrl']?.toString() ?? '',
    );
  }

  @override
  Future<List<Donation>> getDonationHistory(String donorId) async {
    try {
      final response = await _dio.get('/api/donor/donations');
      final List data = response.data['data']?['items'] ?? const [];
      return data
          .whereType<Map>()
          .map((e) => _mapDonation(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch donation history');
    }
  }

  @override
  Future<List<Donation>> getDonationsByCampaignIds(Set<String> campaignIds) async {
    final history = await getDonationHistory('');
    return history.where((d) => campaignIds.contains(d.campaignId)).toList();
  }

  @override
  Future<Donation?> getDonationById(String donationId) async {
    try {
      final response = await _dio.get('/api/donation/id/$donationId');
      final data = _asMap(response.data['data']);
      final donationData = _asMap(data['donation']);
      return _mapDonation(Map<String, dynamic>.from(donationData));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Donation> setDonationAnonymous({required String donationId, required bool isAnonymous}) async {
    final donation = await getDonationById(donationId);
    if (donation == null) throw Exception('Donation not found');
    return Donation(
      id: donation.id,
      donorId: donation.donorId,
      campaignId: donation.campaignId,
      amount: donation.amount,
      isAnonymous: isAnonymous,
      transactionId: donation.transactionId,
      status: donation.status,
      donatedAt: donation.donatedAt,
      message: donation.message,
      guestName: donation.guestName,
      guestEmail: donation.guestEmail,
    );
  }

  @override
  Future<DonationReceipt> generateReceipt(Donation donation) async {
    try {
      final response = await _dio.get('/api/donation/id/${donation.id}/receipt');
      final data = _asMap(response.data['data']);
      final reference = (data['receiptReference'] ?? data['reference'] ?? 'REC-${donation.id}').toString();
      return DonationReceipt(
        id: reference,
        donationId: donation.id,
        reference: reference,
        issuedAt: data['issuedDate'] != null
            ? DateTime.parse(data['issuedDate'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate receipt');
    }
  }

  @override
  Future<DonationReceipt?> getReceiptByDonationId(String donationId) async {
    try {
      final response = await _dio.get('/api/donation/id/$donationId/receipt');
      final data = _asMap(response.data['data']);
      final reference = (data['receiptReference'] ?? data['reference'] ?? 'REC-$donationId').toString();
      return DonationReceipt(
        id: reference,
        donationId: donationId,
        reference: reference,
        issuedAt: data['issuedDate'] != null
            ? DateTime.parse(data['issuedDate'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<String> initiateChapaCheckout({
    required String campaignId,
    required double amount,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/campaign/$campaignId/donate',
        data: {
          'amount': amount,
          'message': message ?? '',
          'isAnonymous': isAnonymous,
        },
      );

      final checkoutData = _asMap(response.data['data']);
      final chapaData = _asMap(checkoutData['chapa']);

      return chapaData['checkoutUrl']?.toString() ?? '';
    } catch (e) {
      throw Exception('Failed to initiate Chapa checkout');
    }
  }

  Future<Donation> verifyPaymentTransaction(String txRef) async {
    try {
      final response = await _dio.get('/api/donation/$txRef');
      final data = _asMap(response.data['data']);
      final donationData = _asMap(data['donation']);
      return _mapDonation(Map<String, dynamic>.from(donationData));
    } catch (e) {
      throw Exception('Failed to verify payment transaction');
    }
  }

  @override
  Future<Donation?> getDonationByTransactionRef(String txRef) async {
    try {
      final response = await _dio.get('/api/donation/$txRef');
      final data = _asMap(response.data['data']);
      final donationData = _asMap(data['donation']);
      return _mapDonation(Map<String, dynamic>.from(donationData));
    } catch (e) {
      return null;
    }
  }

}
