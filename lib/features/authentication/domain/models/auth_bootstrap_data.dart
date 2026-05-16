import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';

class AuthBootstrapData {
  const AuthBootstrapData({
    required this.onboardingSeen,
    this.user,
    this.selectedRole,
  });

  final bool onboardingSeen;
  final UserProfile? user;
  final UserRole? selectedRole;
}
