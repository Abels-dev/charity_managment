import 'package:charity_managment/models/app_notification.dart';

final mockNotifications = [
  AppNotification(
    id: 'ntf_001',
    userId: 'user_12345',
    title: 'Thank you for donating',
    message: 'Your donation to School Kits for Rural Children was received.',
    isRead: false,
    createdAt: DateTime(2026, 5, 14, 8),
    targetType: NotificationTargetType.donation,
    targetId: 'dn_001',
  ),
  AppNotification(
    id: 'ntf_002',
    userId: 'user_12345',
    title: 'Campaign milestone reached',
    message: 'School Kits for Rural Children reached 60% of its goal.',
    isRead: true,
    createdAt: DateTime(2026, 5, 11, 18, 30),
    targetType: NotificationTargetType.campaign,
    targetId: 'cmp_001',
  ),
];
