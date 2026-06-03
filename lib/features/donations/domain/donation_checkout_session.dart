class DonationCheckoutSession {
  const DonationCheckoutSession({
    required this.donationId,
    required this.txRef,
    required this.checkoutUrl,
  });

  final String donationId;
  final String txRef;
  final String checkoutUrl;
}
