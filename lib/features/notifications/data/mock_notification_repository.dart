import 'package:charity_managment/models/app_notification.dart';
import 'package:charity_managment/repositories/notification_repository.dart';
import 'package:charity_managment/shared/mock_data/mock_notifications.dart';

class MockNotificationRepository implements NotificationRepository {
  static final List<AppNotification> _notifications =
      List<AppNotification>.from(mockNotifications);

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final items = _notifications
        .where((notification) => notification.userId == userId)
        .toList(growable: false);

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<AppNotification> createNotification(AppNotification notification) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _notifications.insert(0, notification);
    return notification;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final index =
        _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index < 0) return;

    final current = _notifications[index];
    if (current.isRead) return;
    _notifications[index] = current.copyWith(isRead: true);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      if (notification.userId == userId && !notification.isRead) {
        _notifications[i] = notification.copyWith(isRead: true);
      }
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _notifications
        .where((notification) => notification.userId == userId && !notification.isRead)
        .length;
  }
}
