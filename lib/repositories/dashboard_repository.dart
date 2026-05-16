import 'package:charity_managment/models/charity_stats.dart';

abstract class DashboardRepository {
  Future<CharityStats> fetchCharityStats();
}
