import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/charity_dashboard/data/api_dashboard_repository.dart';
import 'package:charity_managment/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiDashboardRepository(dio);
});
