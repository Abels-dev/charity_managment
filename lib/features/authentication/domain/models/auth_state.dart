import 'package:charity_managment/features/authentication/domain/models/auth_status.dart';
import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';

class AuthState {
  const AuthState({
    required this.status,
    required this.onboardingSeen,
    this.user,
    this.selectedRole,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool onboardingSeen;
  final UserProfile? user;
  final UserRole? selectedRole;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? onboardingSeen,
    UserProfile? user,
    bool clearUser = false,
    UserRole? selectedRole,
    bool clearSelectedRole = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      user: clearUser ? null : (user ?? this.user),
      selectedRole: clearSelectedRole ? null : (selectedRole ?? this.selectedRole),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const initial = AuthState(
    status: AuthStatus.bootstrapping,
    onboardingSeen: false,
  );
}
