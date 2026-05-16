class AppRoutes {
  static const root = '/';

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const roleSelection = '/auth/role-selection';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';

  static const campaigns = '/campaigns';
  static const campaignDetailPattern = '/campaigns/:campaignId';
  static const donations = '/donations';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const charityDashboard = '/charity-dashboard';

  static String campaignDetail(String campaignId) => '/campaigns/$campaignId';
}
