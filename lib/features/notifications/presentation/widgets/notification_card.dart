import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/models/app_notification.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnread = !notification.isRead;

    return Card(
      color: isUnread ? colorScheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                notification.message,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                CampaignFormatters.shortDate(notification.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
