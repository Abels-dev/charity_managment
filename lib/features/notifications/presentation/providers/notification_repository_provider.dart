import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/notifications/data/api_notification_repository.dart';
import 'package:charity_managment/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiNotificationRepository(dio);
});
