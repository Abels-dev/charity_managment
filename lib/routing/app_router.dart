import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/domain/models/auth_status.dart';
import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:charity_managment/features/authentication/presentation/screens/login_screen.dart';
import 'package:charity_managment/features/authentication/presentation/screens/onboarding_screen.dart';
import 'package:charity_managment/features/authentication/presentation/screens/register_screen.dart';
import 'package:charity_managment/features/authentication/presentation/screens/role_selection_screen.dart';
import 'package:charity_managment/features/authentication/presentation/screens/splash_screen.dart';
import 'package:charity_managment/features/campaigns/presentation/screens/campaign_detail_screen.dart';
import 'package:charity_managment/features/campaigns/presentation/screens/campaigns_screen.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/screens/charity_dashboard_screen.dart';
import 'package:charity_managment/features/donations/presentation/screens/donations_screen.dart';
import 'package:charity_managment/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:charity_managment/features/profile/presentation/screens/profile_screen.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.root,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.campaigns,
        builder: (context, state) => const CampaignsScreen(),
      ),
      GoRoute(
        path: AppRoutes.campaignDetailPattern,
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return CampaignDetailScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: AppRoutes.donations,
        builder: (context, state) => const DonationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.charityDashboard,
        builder: (context, state) => const CharityDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = _authRoutes.contains(location);

      if (auth.status == AuthStatus.bootstrapping) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (auth.isAuthenticated) {
        if (location == AppRoutes.charityDashboard && auth.user?.role == UserRole.donor) {
          return AppRoutes.campaigns;
        }

        if (isAuthRoute || location == AppRoutes.root) {
          return _defaultRouteForRole(auth.user?.role);
        }

        return null;
      }

      if (!auth.onboardingSeen) {
        return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      if (auth.selectedRole == null) {
        return location == AppRoutes.roleSelection ? null : AppRoutes.roleSelection;
      }

      if (_isProtectedLocation(location) ||
          location == AppRoutes.root ||
          location == AppRoutes.splash) {
        return AppRoutes.login;
      }

      return null;
    },
  );
});

const _authRoutes = {
  AppRoutes.root,
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.roleSelection,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

const _protectedRoutes = {
  AppRoutes.campaigns,
  AppRoutes.donations,
  AppRoutes.notifications,
  AppRoutes.profile,
  AppRoutes.charityDashboard,
};

bool _isProtectedLocation(String location) {
  if (_protectedRoutes.contains(location)) {
    return true;
  }

  return location.startsWith('${AppRoutes.campaigns}/');
}

String _defaultRouteForRole(UserRole? role) {
  if (role == UserRole.charityOrganization) {
    return AppRoutes.charityDashboard;
  }
  return AppRoutes.campaigns;
}
