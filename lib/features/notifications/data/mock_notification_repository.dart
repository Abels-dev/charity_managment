import 'package:charity_managment/models/app_notification.dart';
import 'package:charity_managment/repositories/notification_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_notifications.dart';

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return mockNotifications;
  }
}
