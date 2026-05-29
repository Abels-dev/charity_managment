import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';
import 'package:dio/dio.dart';

class ApiCampaignRequestRepository {
  ApiCampaignRequestRepository(this._dio);

  final Dio _dio;

  CampaignRequestStatus _mapStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'APPROVED':
        return CampaignRequestStatus.approved;
      case 'REJECTED':
        return CampaignRequestStatus.rejected;
      case 'PENDING':
      default:
        return CampaignRequestStatus.pending;
    }
  }

  CampaignRequest _mapCampaignRequest(Map<String, dynamic> json) {
    final charity = json['charity'] is Map ? Map<String, dynamic>.from(json['charity'] as Map) : const <String, dynamic>{};

    return CampaignRequest(
      id: json['id']?.toString() ?? '',
      charityName: charity['organizationName']?.toString() ?? json['charityName']?.toString() ?? '',
      campaignTitle: json['reason']?.toString() ?? json['campaignTitle']?.toString() ?? 'Campaign request',
      status: _mapStatus(json['status']?.toString()),
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      message: json['reason']?.toString(),
    );
  }

  List<CampaignRequest> _mapCampaignRequests(dynamic source) {
    if (source is! List) return const <CampaignRequest>[];

    return source
        .whereType<Map>()
        .map((e) => _mapCampaignRequest(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<CampaignRequest> submitCampaignRequest({
    required String reason,
  }) async {
    final response = await _dio.post(
      '/api/campaign-request',
      data: {'reason': reason},
    );
    return _mapCampaignRequest(Map<String, dynamic>.from(response.data['data']));
  }

  Future<List<CampaignRequest>> getMyCampaignRequests() async {
    final response = await _dio.get('/api/campaign-request/me');
    final List items = response.data['data']?['items'] ?? response.data['data'] ?? [];
    return _mapCampaignRequests(items);
  }

  Future<List<CampaignRequest>> getAdminCampaignRequests() async {
    final response = await _dio.get('/api/campaign-request/admin');
    final List items = response.data['data']?['items'] ?? response.data['data'] ?? [];
    return _mapCampaignRequests(items);
  }

  Future<CampaignRequest> approveCampaignRequest(String requestId) async {
    final response = await _dio.put('/api/campaign-request/admin/$requestId/approve');
    return _mapCampaignRequest(Map<String, dynamic>.from(response.data['data']));
  }

  Future<CampaignRequest> rejectCampaignRequest({
    required String requestId,
  }) async {
    final response = await _dio.put('/api/campaign-request/admin/$requestId/reject');
    return _mapCampaignRequest(Map<String, dynamic>.from(response.data['data']));
  }
}
