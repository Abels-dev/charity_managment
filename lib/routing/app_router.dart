import 'package:flutter/foundation.dart';
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
import 'package:charity_managment/features/campaigns/presentation/screens/create_campaign_screen.dart';
import 'package:charity_managment/features/campaigns/presentation/screens/edit_campaign_screen.dart';
import 'package:charity_managment/features/campaigns/presentation/screens/followed_campaigns_screen.dart';
import 'package:charity_managment/features/campaigns/presentation/screens/my_campaigns_screen.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/screens/charity_dashboard_screen.dart';
import 'package:charity_managment/features/donor_dashboard/presentation/screens/donor_dashboard_screen.dart';
import 'package:charity_managment/features/bank_accounts/presentation/screens/bank_accounts_screen.dart';
import 'package:charity_managment/features/donations/presentation/screens/anonymous_donations_screen.dart';
import 'package:charity_managment/features/donations/presentation/screens/donations_screen.dart';
import 'package:charity_managment/features/donations/presentation/screens/donation_detail_screen.dart';
import 'package:charity_managment/features/donations/presentation/screens/donation_success_screen.dart';
import 'package:charity_managment/features/donations/presentation/screens/donation_receipt_screen.dart';
import 'package:charity_managment/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:charity_managment/features/profile/presentation/screens/profile_home_screen.dart';
import 'package:charity_managment/features/public_home/presentation/screens/public_home_screen.dart';
import 'package:charity_managment/features/charities/presentation/screens/charity_public_profile_screen.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/screens/charity_contributions_screen.dart';
import 'package:charity_managment/features/campaign_requests/presentation/screens/campaign_requests_screen.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

/// A [ChangeNotifier] that listens to [authControllerProvider] and notifies
/// the router whenever auth state changes, triggering a redirect evaluation.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    // Listen to the auth provider; any state change triggers notifyListeners
    // which causes GoRouter to re-run its redirect function.
    ref.listen(authControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Read current auth state at the time the redirect runs (not captured
      // at construction time), so it always reflects the latest value.
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthFlowRoute = _authFlowRoutes.contains(location);

      if (auth.status == AuthStatus.bootstrapping) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (auth.isAuthenticated) {
        final role = auth.user?.role;

        if (location == AppRoutes.charityDashboard && auth.user?.role == UserRole.donor) {
          return AppRoutes.campaigns;
        }

        if (role == UserRole.donor && _isCharityOnlyLocation(location)) {
          return AppRoutes.campaigns;
        }

        if (role == UserRole.charityOrganization && _isDonorOnlyLocation(location)) {
          return _defaultRouteForRole(role);
        }

        if (role == UserRole.charityOrganization && location == AppRoutes.followedCampaigns) {
          return AppRoutes.myCampaigns;
        }

        if (isAuthFlowRoute || location == AppRoutes.root) {
          return _defaultRouteForRole(role);
        }

        return null;
      }

      if (location == AppRoutes.splash) {
        return AppRoutes.root;
      }

      if (!auth.onboardingSeen && isAuthFlowRoute) {
        return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      if (auth.selectedRole == null && _requiresRoleSelection(location)) {
        return location == AppRoutes.roleSelection ? null : AppRoutes.roleSelection;
      }

      if (_isProtectedLocation(location) || location == AppRoutes.splash) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const PublicHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.charityProfilePattern,
        builder: (context, state) {
          final charityId = state.pathParameters['charityId']!;
          return CharityPublicProfileScreen(charityId: charityId);
        },
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
        path: AppRoutes.createCampaign,
        builder: (context, state) => const CreateCampaignScreen(),
      ),
      GoRoute(
        path: AppRoutes.editCampaignPattern,
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return EditCampaignScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: AppRoutes.campaignDetailPattern,
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId']!;
          return CampaignDetailScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: AppRoutes.followedCampaigns,
        builder: (context, state) => const FollowedCampaignsScreen(),
      ),
      GoRoute(
        path: AppRoutes.myCampaigns,
        builder: (context, state) => const MyCampaignsScreen(),
      ),
      GoRoute(
        path: AppRoutes.donations,
        builder: (context, state) => const DonationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.anonymoETBonations,
        builder: (context, state) => const AnonymoETBonationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.donationDetailPattern,
        builder: (context, state) {
          final donationId = state.pathParameters['donationId']!;
          return DonationDetailScreen(donationId: donationId);
        },
      ),
      GoRoute(
        path: AppRoutes.donationSuccessPattern,
        builder: (context, state) {
          final donationId = state.pathParameters['donationId']!;
          return DonationSuccessScreen(donationId: donationId);
        },
      ),
      GoRoute(
        path: AppRoutes.donationReceiptPattern,
        builder: (context, state) {
          final donationId = state.pathParameters['donationId']!;
          return DonationReceiptScreen(donationId: donationId);
        },
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
        path: AppRoutes.editProfile,
        builder: (context, state) => const ProfileScreen(initiallyEditing: true),
      ),
      GoRoute(
        path: AppRoutes.charityDashboard,
        builder: (context, state) => const CharityDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.donorDashboard,
        builder: (context, state) => const DonorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.charityContributions,
        builder: (context, state) => const CharityContributionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.charityCampaignRequests,
        builder: (context, state) => const CampaignRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.bankAccounts,
        builder: (context, state) => const BankAccountsScreen(),
      ),
    ],
  );
});

const _authFlowRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.roleSelection,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

const _protectedRoutes = {
  AppRoutes.followedCampaigns,
  AppRoutes.myCampaigns,
  AppRoutes.createCampaign,
  AppRoutes.donations,
  AppRoutes.anonymoETBonations,
  AppRoutes.notifications,
  AppRoutes.profile,
  AppRoutes.editProfile,
  AppRoutes.charityDashboard,
  AppRoutes.charityContributions,
  AppRoutes.charityCampaignRequests,
  AppRoutes.bankAccounts,
};

bool _isProtectedLocation(String location) {
  if (_protectedRoutes.contains(location)) {
    return true;
  }

  return location.startsWith('${AppRoutes.donations}/');
}

bool _isDonorOnlyLocation(String location) {
  if (location == AppRoutes.donations ||
      location == AppRoutes.anonymoETBonations) {
    return true;
  }

  return location.startsWith('${AppRoutes.donations}/');
}

bool _isCharityOnlyLocation(String location) {
  if (location == AppRoutes.myCampaigns ||
      location == AppRoutes.createCampaign ||
      location == AppRoutes.charityContributions ||
      location == AppRoutes.charityCampaignRequests ||
      location == AppRoutes.bankAccounts) {
    return true;
  }

  return location.endsWith('/edit');
}

bool _requiresRoleSelection(String location) {
  if (location == AppRoutes.login || location == AppRoutes.register) {
    return true;
  }
  return false;
}

String _defaultRouteForRole(UserRole? role) {
  if (role == UserRole.charityOrganization) {
    return AppRoutes.charityDashboard;
  }
  return AppRoutes.campaigns;
}
