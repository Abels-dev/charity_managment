import 'package:charity_managment/models/app_notification.dart';

const mockNotifications = [
  AppNotification(
    id: 'ntf_001',
    title: 'Thank you for donating',
    body: 'Your donation to School Kits for Rural Children was received.',
    createdAtIso: '2026-05-14T08:00:00Z',
  ),
  AppNotification(
    id: 'ntf_002',
    title: 'Campaign milestone reached',
    body: 'School Kits for Rural Children reached 60% of its goal.',
    createdAtIso: '2026-05-11T18:30:00Z',
    readAtIso: '2026-05-12T08:00:00Z',
  ),
];
