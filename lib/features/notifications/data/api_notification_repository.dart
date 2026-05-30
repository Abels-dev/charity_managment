import 'package:charity_managment/models/app_notification.dart';
import 'package:charity_managment/repositories/notification_repository.dart';
import 'package:dio/dio.dart';

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._dio);

  final Dio _dio;

  String? _targetTypeFromNotification(Map<String, dynamic> json) {
    final notificationType = json['type']?.toString().toUpperCase();
    switch (notificationType) {
      case 'DONATION':
        return NotificationTargetType.donation.value;
      case 'CAMPAIGN':
        return NotificationTargetType.campaign.value;
      default:
        final metadata = json['metadata'];
        if (metadata is Map) {
          final meta = Map<String, dynamic>.from(metadata);
          if (meta['donationId'] != null) return NotificationTargetType.donation.value;
          if (meta['campaignId'] != null) return NotificationTargetType.campaign.value;
        }
        return null;
    }
  }

  AppNotification _mapNotification(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    final metadataMap = metadata is Map ? Map<String, dynamic>.from(metadata) : const <String, dynamic>{};

    return AppNotification(
      id: json['id'].toString(),
      userId: json['userId']?.toString() ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      targetType: NotificationTargetType.fromJson(_targetTypeFromNotification(json)),
      targetId: metadataMap['campaignId']?.toString() ?? metadataMap['donationId']?.toString(),
    );
  }

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final response = await _dio.get('/api/notifications');
      final List data = response.data['data']?['items'] ?? const [];
      return data
          .whereType<Map>()
          .map((e) => _mapNotification(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch notifications');
    }
  }

  @override
  Future<AppNotification> createNotification(AppNotification notification) async {
    return notification;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch('/api/notifications/$notificationId/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _dio.patch('/api/notifications/read-all');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotifications(userId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }
}
