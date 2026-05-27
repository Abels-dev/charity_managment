import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/features/charity_dashboard/domain/campaign_analytics.dart';

class CampaignAnalyticsCard extends StatelessWidget {
  const CampaignAnalyticsCard({
    super.key,
    required this.analytics,
    required this.onView,
    required this.onEdit,
    required this.onClose,
    required this.isClosing,
  });

  final CampaignAnalytics analytics;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final bool isClosing;

  @override
  Widget build(BuildContext context) {
    final canEdit = analytics.isClosed == false;
    final canClose = analytics.isActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    analytics.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                CampaignStatusBadge(status: analytics.status),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: analytics.progress),
            const SizedBox(height: 6),
            Text(
              '${CampaignFormatters.percent(analytics.progress)} • ${CampaignFormatters.money(analytics.currentAmount)} / ${CampaignFormatters.money(analytics.targetAmount)}',
            ),
            const SizedBox(height: 6),
            Text('${analytics.donorCount} donors'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onView,
                  child: const Text('View'),
                ),
                OutlinedButton(
                  onPressed: canEdit ? onEdit : null,
                  child: const Text('Edit'),
                ),
                FilledButton(
                  onPressed: (canClose && !isClosing) ? onClose : null,
                  child: isClosing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
