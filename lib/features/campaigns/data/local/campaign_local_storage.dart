import 'package:shared_preferences/shared_preferences.dart';

class CampaignLocalStorage {
  static const _followedCampaignIdsKey = 'campaign.followed_ids';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Set<String>> readFollowedCampaignIds() async {
    final prefs = await _instance();
    final values = prefs.getStringList(_followedCampaignIdsKey) ?? const [];
    return values.toSet();
  }

  Future<void> saveFollowedCampaignIds(Set<String> ids) async {
    final prefs = await _instance();
    await prefs.setStringList(_followedCampaignIdsKey, ids.toList());
  }
}
