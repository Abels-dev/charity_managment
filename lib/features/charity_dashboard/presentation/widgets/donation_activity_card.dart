import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/charity_dashboard/domain/donation_activity.dart';
import 'package:charity_managment/features/charity_dashboard/presentation/utils/dashboard_formatters.dart';

class DonationActivityCard extends StatelessWidget {
  const DonationActivityCard({
    super.key,
    required this.activity,
  });

  final DonationActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(
                activity.donorName.isNotEmpty
                    ? activity.donorName.substring(0, 1).toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.donorName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        CampaignFormatters.money(activity.amount),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.campaignName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DashboardFormatters.shortDateTime(activity.donatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
