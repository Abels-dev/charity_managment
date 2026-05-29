class DonationCheckoutSession {
  const DonationCheckoutSession({
    required this.donationId,
    required this.txRef,
    required this.actionUrl,
    required this.fields,
  });

  final String donationId;
  final String txRef;
  final String actionUrl;
  final Map<String, dynamic> fields;
}
