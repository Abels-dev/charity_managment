class NotificationFollowersRegistry {
  static final Map<String, Set<String>> _campaignFollowers = {};
  static final Map<String, Set<String>> _charityFollowers = {};
  static final Map<String, Set<String>> _userCampaigns = {};
  static final Map<String, String> _campaignCharity = {};

  static void followCampaign({
    required String userId,
    required String campaignId,
    required String charityId,
  }) {
    _campaignFollowers.putIfAbsent(campaignId, () => <String>{}).add(userId);
    _charityFollowers.putIfAbsent(charityId, () => <String>{}).add(userId);
    _userCampaigns.putIfAbsent(userId, () => <String>{}).add(campaignId);
    _campaignCharity[campaignId] = charityId;
  }

  static void unfollowCampaign({
    required String userId,
    required String campaignId,
    required String charityId,
  }) {
    _campaignFollowers[campaignId]?.remove(userId);
    if (_campaignFollowers[campaignId]?.isEmpty ?? false) {
      _campaignFollowers.remove(campaignId);
    }

    _userCampaigns[userId]?.remove(campaignId);
    if (_userCampaigns[userId]?.isEmpty ?? false) {
      _userCampaigns.remove(userId);
    }

    final hasOtherCampaigns =
        _userCampaigns[userId]?.any((id) => _campaignCharity[id] == charityId) ??
            false;
    if (!hasOtherCampaigns) {
      _charityFollowers[charityId]?.remove(userId);
      if (_charityFollowers[charityId]?.isEmpty ?? false) {
        _charityFollowers.remove(charityId);
      }
    }
  }

  static Set<String> followersForCampaign(String campaignId) {
    return {...?_campaignFollowers[campaignId]};
  }

  static Set<String> followersForCharity(String charityId) {
    return {...?_charityFollowers[charityId]};
  }
}
