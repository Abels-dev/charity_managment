import 'dart:developer' as developer;

import 'package:charity_managment/features/authentication/data/local/auth_local_storage.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_bootstrap_data.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_failure.dart';
import 'package:charity_managment/features/authentication/domain/models/login_request.dart';
import 'package:charity_managment/features/authentication/domain/models/register_request.dart';
import 'package:charity_managment/core/network/token_storage.dart';
import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/repositories/auth_repository.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._localStorage, this._cookieJar, this._tokenStorage);

  final Dio _dio;
  final AuthLocalStorage _localStorage;
  final CookieJar _cookieJar;
  final TokenStorage _tokenStorage;

  String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    if (text == null || text.isEmpty || text == 'null') return fallback;
    return text;
  }

  UserRole _mapRole(dynamic value, {UserRole fallback = UserRole.donor}) {
    final normalized = value?.toString().trim().toUpperCase();
    switch (normalized) {
      case 'CHARITY':
      case 'CHARITY_ORGANIZATION':
      case 'CHARITYORGANIZATION':
        return UserRole.charityOrganization;
      case 'DONOR':
        return UserRole.donor;
      default:
        return fallback;
    }
  }

  UserProfile _mapUser(Map<String, dynamic> data, {UserRole? fallbackRole}) {
    return UserProfile(
      id: _asString(data['id']),
      fullName: _asString(data['name'], fallback: 'Member'),
      email: _asString(data['email']),
      role: _mapRole(data['role'], fallback: fallbackRole ?? UserRole.donor),
      avatarUrl: data['avatarUrl']?.toString() ?? data['profileImage']?.toString(),
    );
  }

  @override
  Future<AuthBootstrapData> readBootstrapData() async {
    final onboardingSeen = await _localStorage.readOnboardingSeen();
    final selectedRole = await _localStorage.readSelectedRole();

    UserProfile? user;

    try {
      final response = await _dio.get('/api/auth/me');
      if (response.statusCode == 200) {
        final data = (response.data['user'] as Map<String, dynamic>?) ?? const {};
        user = _mapUser(data, fallbackRole: selectedRole ?? UserRole.donor);
        await _localStorage.saveSession(user);
        developer.log('Session restored for ${user.email}', name: 'ApiAuthRepository');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      developer.log(
        'Bootstrap /api/auth/me failed (status=$status) — treating as unauthenticated.',
        name: 'ApiAuthRepository',
      );
      await _cookieJar.deleteAll();
      await _localStorage.clearSession();
    } catch (e) {
      developer.log(
        'Bootstrap unexpected error: $e — treating as unauthenticated.',
        name: 'ApiAuthRepository',
      );
      await _cookieJar.deleteAll();
      await _localStorage.clearSession();
    }

    return AuthBootstrapData(
      onboardingSeen: onboardingSeen,
      selectedRole: selectedRole,
      user: user,
    );
  }

  @override
  Future<void> markOnboardingSeen() async {
    await _localStorage.saveOnboardingSeen();
  }

  @override
  Future<void> saveSelectedRole(UserRole role) async {
    await _localStorage.saveSelectedRole(role);
  }

  @override
  Future<UserProfile> login({
    required LoginRequest request,
    required UserRole role,
  }) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': request.email,
        'password': request.password,
      });

      final data = (response.data['user'] as Map<String, dynamic>?) ?? const {};
      final user = _mapUser(data, fallbackRole: role);
      final token = response.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
      }

      await _localStorage.saveSession(user);
      await _localStorage.saveSelectedRole(role);

      developer.log(
        'Login successful for ${user.email} as ${user.role}',
        name: 'ApiAuthRepository',
      );
      return user;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data['message'] ?? 'Login failed')
          : 'Login failed';
      developer.log('Login error: $message', name: 'ApiAuthRepository');
      throw AuthFailure(message.toString());
    }
  }

  @override
  Future<UserProfile> register({
    required RegisterRequest request,
    required UserRole role,
  }) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        'name': request.fullName,
        'email': request.email,
        'password': request.password,
        'role': role == UserRole.charityOrganization ? 'CHARITY' : 'DONOR',
      });

      final data = (response.data['user'] as Map<String, dynamic>?) ?? const {};
      final user = _mapUser(data, fallbackRole: role);
      final token = response.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
      }

      await _localStorage.saveSession(user);
      await _localStorage.saveSelectedRole(role);

      developer.log(
        'Registration successful for ${user.email} as ${user.role}',
        name: 'ApiAuthRepository',
      );
      return user;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data['message'] ?? 'Registration failed')
          : 'Registration failed';
      developer.log('Register error: $message', name: 'ApiAuthRepository');
      throw AuthFailure(message.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _dio.post('/api/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data['message'] ?? 'Failed to send reset email')
          : 'Failed to send reset email';
      throw AuthFailure(message.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (e) {
      developer.log('Logout network error (ignored): $e', name: 'ApiAuthRepository');
    } finally {
      await _cookieJar.deleteAll();
      await _tokenStorage.clearToken();
      await _localStorage.clearSession();
      developer.log('Local session cleared.', name: 'ApiAuthRepository');
    }
  }
}

