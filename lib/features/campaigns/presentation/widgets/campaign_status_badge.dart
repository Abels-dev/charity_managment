import 'package:flutter/material.dart';

import 'package:charity_managment/models/campaign.dart';

class CampaignStatusBadge extends StatelessWidget {
  const CampaignStatusBadge({
    super.key,
    required this.status,
  });

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (bg, fg) = switch (status) {
      CampaignStatus.active => (
          colorScheme.primary.withValues(alpha: 0.14),
          colorScheme.primary,
        ),
      CampaignStatus.closed => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
      CampaignStatus.draft => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
