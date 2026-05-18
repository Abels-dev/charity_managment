import 'package:charity_managment/models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);

  Future<AppNotification> createNotification(AppNotification notification);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<int> getUnreadCount(String userId);
}
