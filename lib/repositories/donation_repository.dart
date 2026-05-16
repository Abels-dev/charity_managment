import 'package:charity_managment/models/donation.dart';

abstract class DonationRepository {
  Future<List<Donation>> fetchDonations();
}
