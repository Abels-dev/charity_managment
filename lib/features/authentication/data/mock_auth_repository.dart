import 'package:charity_managment/features/authentication/data/local/auth_local_storage.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_bootstrap_data.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_failure.dart';
import 'package:charity_managment/features/authentication/domain/models/login_request.dart';
import 'package:charity_managment/features/authentication/domain/models/register_request.dart';
import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._localStorage);

  final AuthLocalStorage _localStorage;

  @override
  Future<AuthBootstrapData> readBootstrapData() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final onboardingSeen = await _localStorage.readOnboardingSeen();
    final selectedRole = await _localStorage.readSelectedRole();
    final session = await _localStorage.readSession();

    return AuthBootstrapData(
      onboardingSeen: onboardingSeen,
      selectedRole: selectedRole,
      user: session,
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
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!_isValidEmail(request.email)) {
      throw const AuthFailure('Please enter a valid email address.');
    }

    if (request.password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters.');
    }

    if (request.email.contains('fail')) {
      throw const AuthFailure('Mock login failed. Try another email.');
    }

    final user = UserProfile(
      id: 'user_${request.email.hashCode.abs()}',
      fullName: _nameFromEmail(request.email),
      email: request.email.trim().toLowerCase(),
      role: role,
    );

    await _localStorage.saveSession(user);
    await _localStorage.saveSelectedRole(role);
    return user;
  }

  @override
  Future<UserProfile> register({
    required RegisterRequest request,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (request.fullName.trim().length < 3) {
      throw const AuthFailure('Full name must be at least 3 characters.');
    }

    if (!_isValidEmail(request.email)) {
      throw const AuthFailure('Please enter a valid email address.');
    }

    if (request.password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters.');
    }

    final user = UserProfile(
      id: 'user_${request.email.hashCode.abs()}',
      fullName: request.fullName.trim(),
      email: request.email.trim().toLowerCase(),
      role: role,
    );

    await _localStorage.saveSession(user);
    await _localStorage.saveSelectedRole(role);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!_isValidEmail(email)) {
      throw const AuthFailure('Please enter a valid email address.');
    }
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _localStorage.clearSession();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'Member';
    final text = local.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim();
    if (text.isEmpty) return 'Member';
    return text
        .split(RegExp(r'\s+'))
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
