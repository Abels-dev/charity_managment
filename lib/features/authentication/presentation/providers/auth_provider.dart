import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/data/local/auth_local_storage.dart';
import 'package:charity_managment/features/authentication/data/mock_auth_repository.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_failure.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_state.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_status.dart';
import 'package:charity_managment/features/authentication/domain/models/login_request.dart';
import 'package:charity_managment/features/authentication/domain/models/register_request.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/repositories/auth_repository.dart';

final authLocalStorageProvider = Provider<AuthLocalStorage>((ref) {
  return AuthLocalStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(authLocalStorageProvider);
  return MockAuthRepository(storage);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(AuthState.initial) {
    bootstrap();
  }

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    try {
      final data = await _repository.readBootstrapData();

      state = state.copyWith(
        status: data.user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
        onboardingSeen: data.onboardingSeen,
        user: data.user,
        clearUser: data.user == null,
        selectedRole: data.selectedRole,
        isSubmitting: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        onboardingSeen: false,
        isSubmitting: false,
        errorMessage: 'Unable to restore session. Please continue.',
      );
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.markOnboardingSeen();
      state = state.copyWith(
        onboardingSeen: true,
        isSubmitting: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to continue. Please try again.',
      );
    }
  }

  Future<void> selectRole(UserRole role) async {
    try {
      await _repository.saveSelectedRole(role);
      state = state.copyWith(selectedRole: role, clearError: true);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Unable to save selected role.');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final role = state.selectedRole;
    if (role == null) {
      state = state.copyWith(errorMessage: 'Please select a role before login.');
      return;
    }

    await _runAuthFlow(() async {
      final user = await _repository.login(
        request: LoginRequest(email: email, password: password),
        role: role,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isSubmitting: false,
        clearError: true,
      );
    });
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final role = state.selectedRole;
    if (role == null) {
      state = state.copyWith(errorMessage: 'Please select a role before registration.');
      return;
    }

    await _runAuthFlow(() async {
      final user = await _repository.register(
        request: RegisterRequest(
          fullName: fullName,
          email: email,
          password: password,
        ),
        role: role,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isSubmitting: false,
        clearError: true,
      );
    });
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(isSubmitting: false, clearError: true);
      return true;
    } on AuthFailure catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to send reset email. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        isSubmitting: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to sign out right now.',
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> _runAuthFlow(Future<void> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await action();
    } on AuthFailure catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
