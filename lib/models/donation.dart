class Donation {
  const Donation({
    required this.id,
    required this.campaignId,
    required this.donorId,
    required this.amount,
    required this.currency,
    required this.donatedAtIso,
    this.message,
  });

  final String id;
  final String campaignId;
  final String donorId;
  final double amount;
  final String currency;
  final String donatedAtIso;
  final String? message;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'donorId': donorId,
      'amount': amount,
      'currency': currency,
      'donatedAtIso': donatedAtIso,
      'message': message,
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      donorId: json['donorId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      donatedAtIso: json['donatedAtIso'] as String,
      message: json['message'] as String?,
    );
  }
}
