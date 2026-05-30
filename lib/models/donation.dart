enum DonationStatus {
  pending,
  completed,
  failed,
  refunded;

  String get value => switch (this) {
        DonationStatus.pending => 'PENDING',
        DonationStatus.completed => 'COMPLETED',
        DonationStatus.failed => 'FAILED',
        DonationStatus.refunded => 'REFUNDED',
      };

  String get label => value;

  static DonationStatus fromJson(String value) {
    return DonationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DonationStatus.pending,
    );
  }
}

class Donation {
  const Donation({
    required this.id,
    required this.donorId,
    required this.campaignId,
    required this.amount,
    required this.isAnonymous,
    required this.transactionId,
    required this.status,
    required this.donatedAt,
    this.message,
    this.guestName,
    this.guestEmail,
  });

  final String id;
  final String donorId;
  final String campaignId;
  final double amount;
  final bool isAnonymous;
  final String transactionId;
  final DonationStatus status;
  final DateTime donatedAt;
  final String? message;
  final String? guestName;
  final String? guestEmail;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'campaignId': campaignId,
      'amount': amount,
      'isAnonymous': isAnonymous,
      'message': message,
      'transactionId': transactionId,
      'status': status.value,
      'donatedAt': donatedAt.toIso8601String(),
      'guestName': guestName,
      'guestEmail': guestEmail,
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      donorId: json['donorId']?.toString() ?? '',
      campaignId: json['campaignId'] as String,
      amount: (json['amount'] as num).toDouble(),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      message: json['message'] as String?,
      transactionId: json['transactionId'] as String,
      status: DonationStatus.fromJson(json['status'] as String),
      donatedAt: DateTime.parse(json['donatedAt'] as String),
      guestName: json['guestName'] as String?,
      guestEmail: json['guestEmail'] as String?,
    );
  }
}
