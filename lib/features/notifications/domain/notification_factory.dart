import 'package:charity_managment/models/app_notification.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/models/donation.dart';

class NotificationFactory {
  static AppNotification donationCompleted({
    required String userId,
    required Donation donation,
    required Campaign campaign,
  }) {
    return AppNotification(
      id: _nextId(),
      userId: userId,
      title: 'Donation completed',
      message: 'Your donation to ${campaign.title} was successful.',
      isRead: false,
      createdAt: DateTime.now(),
      targetType: NotificationTargetType.donation,
      targetId: donation.id,
    );
  }

  static AppNotification campaignUpdated({
    required String userId,
    required Campaign campaign,
  }) {
    return AppNotification(
      id: _nextId(),
      userId: userId,
      title: 'Campaign updated',
      message: '${campaign.title} has new updates. Check the latest details.',
      isRead: false,
      createdAt: DateTime.now(),
      targetType: NotificationTargetType.campaign,
      targetId: campaign.id,
    );
  }

  static AppNotification campaignClosed({
    required String userId,
    required Campaign campaign,
  }) {
    return AppNotification(
      id: _nextId(),
      userId: userId,
      title: 'Campaign closed',
      message: '${campaign.title} is now closed to new donations.',
      isRead: false,
      createdAt: DateTime.now(),
      targetType: NotificationTargetType.campaign,
      targetId: campaign.id,
    );
  }

  static AppNotification campaignTargetReached({
    required String userId,
    required Campaign campaign,
  }) {
    return AppNotification(
      id: _nextId(),
      userId: userId,
      title: 'Campaign goal reached',
      message: '${campaign.title} has reached its funding goal.',
      isRead: false,
      createdAt: DateTime.now(),
      targetType: NotificationTargetType.campaign,
      targetId: campaign.id,
    );
  }

  static AppNotification newCampaignFromFollowedCharity({
    required String userId,
    required Campaign campaign,
  }) {
    return AppNotification(
      id: _nextId(),
      userId: userId,
      title: 'New campaign from a followed charity',
      message: '${campaign.charityName} launched ${campaign.title}.',
      isRead: false,
      createdAt: DateTime.now(),
      targetType: NotificationTargetType.campaign,
      targetId: campaign.id,
    );
  }

  static String _nextId() {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'ntf_$stamp';
  }
}
