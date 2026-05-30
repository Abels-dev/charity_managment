import 'package:dio/dio.dart';

import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/repositories/charity_repository.dart';

class ApiCharityRepository implements CharityRepository {
  ApiCharityRepository(this._dio);

  final Dio _dio;

  CharityPublicProfile _mapProfile(Map<String, dynamic> json) {
    return CharityPublicProfile.fromJson(json);
  }

  @override
  Future<List<CharityPublicProfile>> fetchCharities() async {
    try {
      // Backend does not expose a dedicated list endpoint for public charities
      // in this API; return empty list to avoid surprising behaviour.
      return <CharityPublicProfile>[];
    } catch (e) {
      throw Exception('Failed to fetch charities');
    }
  }

  @override
  Future<CharityPublicProfile?> getCharityById(String charityId) async {
    try {
      final response = await _dio.get('/api/charity-profile/public/$charityId');
      final data = response.data['profile'] ?? response.data['data'] ?? response.data;
      if (data == null) return null;
      return _mapProfile(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CharityPublicProfile?> getMyProfile() async {
    try {
      final response = await _dio.get('/api/charity-profile/me');
      final data = response.data['profile'] ?? response.data['data'] ?? response.data;
      if (data == null) return null;
      return _mapProfile(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }
}
