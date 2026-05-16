class CampaignFormatters {
  static String money(double value) {
    final whole = value.toStringAsFixed(0);
    return 'USD $whole';
  }

  static String percent(double value) {
    final scaled = (value * 100).clamp(0, 100).toStringAsFixed(0);
    return '$scaled%';
  }

  static String shortDate(String iso) {
    if (iso.length >= 10) {
      return iso.substring(0, 10);
    }
    return iso;
  }
}
