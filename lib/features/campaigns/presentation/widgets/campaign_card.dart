import 'package:flutter/material.dart';

import 'package:charity_managment/features/campaigns/presentation/utils/campaign_formatters.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/models/campaign.dart';

class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.isFollowed,
    required this.onTap,
    required this.onFollowTap,
  });

  final Campaign campaign;
  final bool isFollowed;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
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
                      campaign.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  CampaignStatusBadge(status: campaign.status),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      isFollowed ? Icons.favorite : Icons.favorite_border,
                      color: isFollowed ? colorScheme.error : null,
                    ),
                    onPressed: onFollowTap,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                campaign.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text('By ${campaign.organizationName}'),
              const SizedBox(height: 4),
              Text(
                campaign.category.label,
                style: TextStyle(color: colorScheme.primary),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: campaign.progress),
              const SizedBox(height: 8),
              Text(
                '${CampaignFormatters.percent(campaign.progress)} funded • ${CampaignFormatters.money(campaign.currentAmount)} / ${CampaignFormatters.money(campaign.goalAmount)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
