import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/repositories/dashboard_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_dashboard_stats.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<CharityStats> fetchCharityStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return mockCharityStats;
  }
}
