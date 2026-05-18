class DonationReceipt {
  const DonationReceipt({
    required this.id,
    required this.donationId,
    required this.reference,
    required this.issuedAt,
  });

  final String id;
  final String donationId;
  final String reference;
  final DateTime issuedAt;

  DonationReceipt copyWith({
    String? id,
    String? donationId,
    String? reference,
    DateTime? issuedAt,
  }) {
    return DonationReceipt(
      id: id ?? this.id,
      donationId: donationId ?? this.donationId,
      reference: reference ?? this.reference,
      issuedAt: issuedAt ?? this.issuedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'reference': reference,
      'issuedAt': issuedAt.toIso8601String(),
    };
  }

  factory DonationReceipt.fromJson(Map<String, dynamic> json) {
    return DonationReceipt(
      id: json['id'] as String,
      donationId: json['donationId'] as String,
      reference: json['reference'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
    );
  }
}
