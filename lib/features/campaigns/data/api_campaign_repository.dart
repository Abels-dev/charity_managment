import 'package:charity_managment/features/campaigns/domain/campaign_create_input.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_filters.dart';
import 'package:charity_managment/features/campaigns/domain/campaign_update_input.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/repositories/campaign_repository.dart';
import 'package:dio/dio.dart';

class ApiCampaignRepository implements CampaignRepository {
  ApiCampaignRepository(this._dio);

  final Dio _dio;
  static const _placeholderImageUrl = 'https://image.com';

  Campaign _mapCampaign(Map<String, dynamic> json) {
    final charity = json['charity'] is Map ? json['charity'] as Map<String, dynamic> : null;
    final category = json['category']?.toString();

    return Campaign(
      id: json['id'].toString(),
      charityId: json['charityId']?.toString() ?? charity?['id']?.toString() ?? '',
      charityName: charity?['organizationName']?.toString() ?? json['charityName']?.toString() ?? 'Unknown Charity',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? 'https://via.placeholder.com/600x400',
      targetAmount: _asDouble(json['targetAmount']),
      currentAmount: _asDouble(json['currentAmount']),
      donorCount: _asInt(json['donorCount'] ?? json['_count']?['donations']),
      startDate: _parseDate(json['startDate']) ?? DateTime.now(),
      endDate: _parseDate(json['endDate']) ?? DateTime.now().add(const Duration(days: 30)),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      status: _mapStatus(json['status']?.toString()),
      category: _mapCategory(
        category,
        title: json['title']?.toString(),
        description: json['description']?.toString(),
      ),
      location: json['location']?.toString(),
    );
  }

  List<Campaign> _mapCampaigns(dynamic source) {
    if (source is! List) return const <Campaign>[];

    return source
        .whereType<Map>()
        .map((e) => _mapCampaign(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  CampaignStatus _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CLOSED':
        return CampaignStatus.closed;
      case 'DRAFT':
        return CampaignStatus.draft;
      case 'ACTIVE':
      default:
        return CampaignStatus.active;
    }
  }

  CampaignCategory _mapCategory(
    String? category, {
    String? title,
    String? description,
  }) {
    switch (category?.toLowerCase()) {
      case 'health':
        return CampaignCategory.health;
      case 'food':
        return CampaignCategory.food;
      case 'emergency':
        return CampaignCategory.emergency;
      case 'environment':
        return CampaignCategory.environment;
      case 'education':
        return CampaignCategory.education;
      default:
        final text = '${title ?? ''} ${description ?? ''}'.toLowerCase();
        if (text.contains('health') || text.contains('medical') || text.contains('hospital')) {
          return CampaignCategory.health;
        }
        if (text.contains('food') || text.contains('hunger') || text.contains('meal')) {
          return CampaignCategory.food;
        }
        if (text.contains('emergency') || text.contains('relief') || text.contains('disaster')) {
          return CampaignCategory.emergency;
        }
        if (text.contains('environment') || text.contains('tree') || text.contains('climate')) {
          return CampaignCategory.environment;
        }
        return CampaignCategory.education;
    }
  }

  @override
  Future<List<Campaign>> fetchCampaigns({CampaignFilters filters = const CampaignFilters()}) async {
    try {
      final response = await _dio.get('/api/campaign/all');
      final campaigns = _mapCampaigns(response.data['data']);

      return campaigns.where((campaign) {
        if (filters.category != null && campaign.category != filters.category) {
          return false;
        }

        if (filters.searchQuery.isNotEmpty) {
          final query = filters.searchQuery.toLowerCase();
          return campaign.title.toLowerCase().contains(query) ||
              campaign.description.toLowerCase().contains(query);
        }

        return true;
      }).toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch campaigns');
    }
  }

  @override
  Future<Campaign?> getCampaignById(String campaignId) async {
    try {
      final response = await _dio.get('/api/campaign/public/$campaignId');
      return _mapCampaign(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Set<String>> getFollowedCampaignIds() async {
    try {
      final response = await _dio.get('/api/donor/following');
      final List items = response.data['data']?['items'] ?? const [];
      return items
          .whereType<Map>()
          .map((e) => e['campaignId']?.toString())
          .whereType<String>()
          .toSet();
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> setCampaignFollowed({required String campaignId, required bool followed}) async {
    try {
      await _dio.post('/api/donor/campaign/$campaignId/follow');
    } catch (e) {
      throw Exception('Failed to toggle follow status');
    }
  }

  @override
  Future<List<Campaign>> getMyCampaigns(String charityId) async {
    try {
      final response = await _dio.get('/api/campaign/my-campaigns');
      final List items = response.data['data'] ?? const [];
      return _mapCampaigns(items);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Campaign>> getFollowedCampaigns() async {
    try {
      final response = await _dio.get('/api/donor/following');
      final List items = response.data['data']?['items'] ?? const [];
      return items
          .whereType<Map>()
          .map((e) => e['campaign'])
          .whereType<Map>()
          .map((campaign) => _mapCampaign(Map<String, dynamic>.from(campaign)))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch followed campaigns');
    }
  }

  @override
  Future<Campaign> createCampaign(CampaignCreateInput input) async {
    try {
      final payload = {
        'title': input.title,
        'description': input.description,
        'category': input.category,
        'imageUrl': _placeholderImageUrl,
        'targetAmount': input.targetAmount,
        'startDate': input.startDate.toIso8601String(),
        'endDate': input.endDate.toIso8601String(),
      };

      final response = await _dio.post('/api/campaign/create', data: payload);
      return _mapCampaign(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  @override
  Future<Campaign> updateCampaign(CampaignUpdateInput input) async {
    try {
      final payload = <String, dynamic>{
        'title': input.title,
        'description': input.description,
        'targetAmount': input.targetAmount,
        'endDate': input.endDate.toIso8601String(),
      };

      final response = await _dio.put('/api/campaign/${input.campaignId}', data: payload);
      return _mapCampaign(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update campaign');
    }
  }

  @override
  Future<Campaign> closeCampaign(String campaignId) async {
    try {
      final response = await _dio.put('/api/campaign/$campaignId/close');
      return _mapCampaign(response.data['data']);
    } catch (e) {
      throw Exception('Failed to close campaign');
    }
  }

  @override
  Future<Campaign> applyDonation({required String campaignId, required double amount}) async {
    try {
      await _dio.post('/api/campaign/$campaignId/donate', data: {
        'amount': amount,
      });
    } catch (e) {
      throw Exception('Failed to create donation');
    }

    final campaign = await getCampaignById(campaignId);
    if (campaign == null) throw Exception('Campaign not found');
    return campaign;
  }
}
