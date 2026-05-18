import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/notifications/data/mock_notification_repository.dart';
import 'package:charity_managment/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});
