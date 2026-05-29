import 'package:charity_managment/features/profile/data/local/profile_local_storage.dart';
import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/charity_profile.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/user.dart';
import 'package:charity_managment/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._dio, this._localStorage, {required this.role});

  final Dio _dio;
  final ProfileLocalStorage _localStorage;
  final ProfileRole role;

  @override
  Future<ProfileData> getCurrentUserProfile() async {
    try {
      final userResponse = await _dio.get('/api/auth/profile');
      final dataMap = userResponse.data['data'] ?? {};
      final userData = dataMap['user'] ?? dataMap;

      final userProfile = User(
        id: userData['id']?.toString() ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: role,
        bio: userData['bio'],
        phone: userData['phone'],
        isVerified: userData['isVerified'] ?? false,
        createdAt: userData['createdAt'] != null ? DateTime.parse(userData['createdAt'].toString()) : DateTime.now(),
        updatedAt: userData['updatedAt'] != null ? DateTime.parse(userData['updatedAt'].toString()) : DateTime.now(),
      );

      CharityProfile? charityProfile;
      if (role == ProfileRole.charity) {
        try {
          final charityResponse = await _dio.get('/api/charity-profile/me');
          final charityData = charityResponse.data['profile'];
          
          if (charityData != null) {
            charityProfile = CharityProfile(
              organizationName: charityData['organizationName'] ?? '',
              description: charityData['description'] ?? '',
              documentUrl: charityData['documentUrl'] ?? '',
              phone: charityData['phone'],
              address: charityData['address'],
              website: charityData['website'],
              verifiedAt: charityData['verifiedAt'] != null
                  ? DateTime.tryParse(charityData['verifiedAt'].toString())
                  : null,
            );
          }
        } catch (e) {
          // Charity profile might not exist yet
        }
      }

      final profileData = ProfileData(
        user: userProfile,
        charityProfile: charityProfile,
      );

      await _localStorage.saveProfile(role, profileData);
      return profileData;
    } catch (e) {
      // Fallback to local storage if offline
      final stored = await _localStorage.readProfile(role);
      if (stored != null) return stored;
      throw Exception('Failed to fetch profile data');
    }
  }

  @override
  Future<ProfileData> updateUserProfile(UserProfileUpdateInput input) async {
    try {
      await _dio.put('/api/auth/profile', data: {
        'name': input.name,
        'bio': input.bio,
        'phone': input.phone,
      });
      
      return await getCurrentUserProfile();
    } catch (e) {
      throw Exception('Failed to update user profile');
    }
  }

  @override
  Future<ProfileData> updateCharityProfile(CharityProfileUpdateInput input) async {
    try {
      await _dio.put('/api/charity-profile/me', data: {
        'organizationName': input.organizationName,
        'description': input.description,
        'phone': input.phone,
        'website': input.website,
        'address': input.address,
      });

      return await getCurrentUserProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Charity profile not found. Create it with the required document upload flow first.');
      }
      throw Exception('Failed to update charity profile');
    }
  }

  /// Creates a new charity profile with required document and optional logo uploads
  @override
  Future<ProfileData> createCharityProfile({
    required String organizationName,
    required String description,
    required String documentPath,
    String? logoPath,
    String? phone,
    String? address,
    String? website,
  }) async {
    try {
      final formData = FormData.fromMap({
        'organizationName': organizationName,
        'description': description,
        'phone': phone ?? '',
        'address': address ?? '',
        'website': website ?? '',
      });

      // Add required document file
      try {
        formData.files.add(
          MapEntry(
            'document',
            await MultipartFile.fromFile(
              documentPath,
              filename: documentPath.split('/').last,
            ),
          ),
        );
      } catch (e) {
        throw Exception('Failed to load document file');
      }

      // Add optional logo file
      if (logoPath != null && logoPath.isNotEmpty) {
        try {
          formData.files.add(
            MapEntry(
              'logo',
              await MultipartFile.fromFile(
                logoPath,
                filename: logoPath.split('/').last,
              ),
            ),
          );
        } catch (_) {
          // Logo is optional, so we can skip it if there's an error
        }
      }

      await _dio.post('/api/charity-profile', data: formData);
      return await getCurrentUserProfile();
    } on DioException catch (e) {
      throw Exception('Failed to create charity profile: ${e.message}');
    }
  }
}

