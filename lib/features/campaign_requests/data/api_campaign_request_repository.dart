import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';
import 'package:dio/dio.dart';

class ApiCampaignRequestRepository {
  ApiCampaignRequestRepository(this._dio);

  final Dio _dio;

  static const int _defaultLimit = 6;

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
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      reviewedByName: json['reviewedByName']?.toString(),
      monthCampaignCount: json['monthCampaignCount'] is int ? json['monthCampaignCount'] as int : int.tryParse('${json['monthCampaignCount']}'),
      totalCampaignCount: json['totalCampaignCount'] is int ? json['totalCampaignCount'] as int : int.tryParse('${json['totalCampaignCount']}'),
      activeCampaignCount: json['activeCampaignCount'] is int ? json['activeCampaignCount'] as int : int.tryParse('${json['activeCampaignCount']}'),
    );
  }

  CampaignRequestSummary _mapSummary(Map<String, dynamic> json) {
    int toInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

    return CampaignRequestSummary(
      charityId: json['charityId']?.toString() ?? '',
      organizationName: json['organizationName']?.toString() ?? '',
      currentMonthCampaignCount: toInt(json['currentMonthCampaignCount'] ?? json['monthCampaignCount']),
      totalCampaignCount: toInt(json['totalCampaignCount']),
      activeCampaignCount: toInt(json['activeCampaignCount']),
      pendingRequestCount: toInt(json['pendingRequestCount']),
      approvedAllowanceCount: toInt(json['approvedAllowanceCount']),
      monthlyLimit: toInt(json['monthlyLimit']),
      hasExceededLimit: json['hasExceededLimit'] == true,
      hasApprovedAllowance: json['hasApprovedAllowance'] == true,
    );
  }

  CharityCampaignRequestsResponse _mapCharityRequestsResponse(Map<String, dynamic> json) {
    final summaryJson = json['summary'] is Map ? Map<String, dynamic>.from(json['summary'] as Map) : <String, dynamic>{};
    final items = _mapCampaignRequests(json['items'] ?? json['requests']);
    final statusCounts = <CampaignRequestStatus, int>{};
    final counts = json['statusCounts'] is Map ? Map<String, dynamic>.from(json['statusCounts'] as Map) : const <String, dynamic>{};

    for (final entry in counts.entries) {
      statusCounts[_mapStatus(entry.key)] = entry.value is int ? entry.value as int : int.tryParse(entry.value.toString()) ?? 0;
    }

    return CharityCampaignRequestsResponse(
      summary: _mapSummary(summaryJson),
      items: items,
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total']}') ?? items.length,
      page: json['page'] is int ? json['page'] as int : int.tryParse('${json['page']}') ?? 1,
      limit: json['limit'] is int ? json['limit'] as int : int.tryParse('${json['limit']}') ?? _defaultLimit,
      totalPages: json['totalPages'] is int ? json['totalPages'] as int : int.tryParse('${json['totalPages']}') ?? 1,
      statusCounts: statusCounts,
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
      '/api/campaign-requests',
      data: {'reason': reason},
    );
    return _mapCampaignRequest(Map<String, dynamic>.from(response.data['data']));
  }

  Future<CharityCampaignRequestsResponse> getMyCampaignRequests({
    int page = 1,
    int limit = _defaultLimit,
  }) async {
    final response = await _dio.get(
      '/api/campaign-requests/me',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'];
    return _mapCharityRequestsResponse(data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{});
  }

  Future<CharityCampaignRequestsResponse> getAdminCampaignRequests({
    int page = 1,
    int limit = _defaultLimit,
  }) async {
    final response = await _dio.get(
      '/api/campaign-requests/admin',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'];
    return _mapCharityRequestsResponse(data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{});
  }

  Future<CampaignRequest> approveCampaignRequest(String requestId) async {
    final response = await _dio.put('/api/campaign-requests/admin/$requestId/approve');
    return _mapCampaignRequest(Map<String, dynamic>.from(response.data['data']));
  }

  Future<CampaignRequest> rejectCampaignRequest({
    required String requestId,
  }) async {
    final response = await _dio.put('/api/campaign-requests/admin/$requestId/reject');
    return _mapCampaignRequest(Map<String, dynamic>.from(response.data['data']));
  }
}
