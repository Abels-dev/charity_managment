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
  Future<Donation> createDonation(Donation donation) async {
    try {
      final response = await _dio.post('/api/campaign/${donation.campaignId}/donate', data: {
        'amount': donation.amount,
        'isAnonymous': donation.isAnonymous,
        'message': donation.message,
      });
      final data = _asMap(response.data['data']);
      final donationData = _asMap(data['donation']);
      if (donationData.isEmpty) {
        throw Exception('Donation payload missing');
      }
      return _mapDonation(donationData);
    } catch (e) {
      throw Exception('Failed to create donation');
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
    final fields = _asMap(chapaData['fields']);

    return DonationCheckoutSession(
      donationId: donationData['id']?.toString() ?? donation.id,
      txRef: donationData['transactionId']?.toString() ?? fields['tx_ref']?.toString() ?? '',
      actionUrl: chapaData['actionUrl']?.toString() ?? '',
      fields: fields,
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
    final history = await getDonationHistory('');
    try {
      return history.firstWhere((d) => d.id == donationId);
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
    );
  }

  @override
  Future<DonationReceipt> generateReceipt(Donation donation) async {
    try {
      final response = await _dio.get('/api/donation/${donation.id}/receipt');
      final data = _asMap(response.data['data']);
      return DonationReceipt(
        id: data['id'].toString(),
        donationId: donation.id,
        reference: (data['receiptReference'] ?? data['reference'] ?? 'REC-${donation.id}').toString(),
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
    final donation = await getDonationById(donationId);
    if (donation == null) return null;
    return generateReceipt(donation);
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
      final checkoutSession = _asMap(checkoutData['checkout']);

      return checkoutSession['checkoutUrl'] ?? 
             checkoutSession['redirectUrl'] ?? 
             checkoutSession['txRef'] ?? 
             '';
    } catch (e) {
      throw Exception('Failed to initiate Chapa checkout');
    }
  }

  Future<Donation> verifyPaymentTransaction(String txRef) async {
    try {
      final response = await _dio.get('/api/donation/$txRef');
      final data = _asMap(response.data['data']);
      return _mapDonation(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('Failed to verify payment transaction');
    }
  }

  @override
  Future<Donation?> getDonationByTransactionRef(String txRef) async {
    try {
      final response = await _dio.get('/api/donation/$txRef');
      final data = _asMap(response.data['data']);
      return _mapDonation(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }
}

