import 'package:charity_managment/features/authentication/domain/models/auth_bootstrap_data.dart';
import 'package:charity_managment/features/authentication/domain/models/login_request.dart';
import 'package:charity_managment/features/authentication/domain/models/register_request.dart';
import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';

abstract class AuthRepository {
  Future<AuthBootstrapData> readBootstrapData();
  Future<void> markOnboardingSeen();
  Future<void> saveSelectedRole(UserRole role);
  Future<UserProfile> login({
    required LoginRequest request,
    required UserRole role,
  });
  Future<UserProfile> register({
    required RegisterRequest request,
    required UserRole role,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
}
