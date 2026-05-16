import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/models/campaign.dart';

class MyCampaignCard extends StatelessWidget {
  const MyCampaignCard({
    super.key,
    required this.campaign,
    required this.onView,
    required this.onEdit,
    required this.onClose,
    required this.isClosing,
  });

  final Campaign campaign;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final bool isClosing;

  @override
  Widget build(BuildContext context) {
    final canEdit = campaign.status != CampaignStatus.closed;
    final canClose = campaign.status == CampaignStatus.active;

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
                    campaign.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                CampaignStatusBadge(status: campaign.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(campaign.summary),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: campaign.progress),
            const SizedBox(height: 6),
            Text(
              '${CampaignFormatters.percent(campaign.progress)} • ${CampaignFormatters.money(campaign.currentAmount)} / ${CampaignFormatters.money(campaign.targetAmount)}',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onView,
                  child: const Text('View Campaign'),
                ),
                OutlinedButton(
                  onPressed: canEdit ? onEdit : null,
                  child: const Text('Edit Campaign'),
                ),
                FilledButton(
                  onPressed: (canClose && !isClosing) ? onClose : null,
                  child: isClosing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Close Campaign'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
