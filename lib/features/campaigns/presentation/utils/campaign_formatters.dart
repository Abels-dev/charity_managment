class CampaignFormatters {
  static String money(double value) {
    final whole = value.toStringAsFixed(0);
    return 'USD $whole';
  }

  static String percent(double value) {
    final scaled = (value * 100).clamp(0, 100).toStringAsFixed(0);
    return '$scaled%';
  }

  static String shortDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
