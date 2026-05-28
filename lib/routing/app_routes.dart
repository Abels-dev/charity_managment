class AppRoutes {
  static const root = '/';
  static const charityProfilePattern = '/charities/:charityId';

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const roleSelection = '/auth/role-selection';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';

  static const campaigns = '/campaigns';
  static const campaignDetailPattern = '/campaigns/:campaignId';
  static const followedCampaigns = '/followed-campaigns';
  static const myCampaigns = '/my-campaigns';
  static const createCampaign = '/campaigns/create';
  static const editCampaignPattern = '/campaigns/:campaignId/edit';
  static const donations = '/donations';
  static const anonymousDonations = '/dashboard/anonymous-donations';
  static const donationDetailPattern = '/donations/:donationId';
  static const donationSuccessPattern = '/donations/:donationId/success';
  static const donationReceiptPattern = '/donations/:donationId/receipt';
  static const charityContributions = '/charity/contributions';
  static const charityCampaignRequests = '/charity/campaign-requests';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const charityDashboard = '/charity-dashboard';

  static String charityProfile(String charityId) => '/charities/$charityId';

  static String campaignDetail(String campaignId) => '/campaigns/$campaignId';
  static String editCampaign(String campaignId) => '/campaigns/$campaignId/edit';
  static String donationDetail(String donationId) => '/donations/$donationId';
  static String donationSuccess(String donationId) => '/donations/$donationId/success';
  static String donationReceipt(String donationId) => '/donations/$donationId/receipt';
}
