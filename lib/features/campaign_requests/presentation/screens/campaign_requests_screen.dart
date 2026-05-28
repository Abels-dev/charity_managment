import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';
import 'package:charity_managment/features/campaign_requests/presentation/providers/campaign_requests_provider.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class CampaignRequestsScreen extends ConsumerWidget {
  const CampaignRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(campaignRequestsProvider);

    return AppScaffold(
      title: 'Campaign Requests',
      drawer: const AppNavigationDrawer(),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load requests',
          subtitle: error.toString(),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyState(
              title: 'No campaign requests',
              subtitle: 'Submitted requests will appear here for review.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(campaignRequestsProvider);
              await ref.read(campaignRequestsProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _RequestCard(request: requests[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final CampaignRequest request;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (request.status) {
      CampaignRequestStatus.pending => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      CampaignRequestStatus.approved => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      CampaignRequestStatus.rejected => (colorScheme.errorContainer, colorScheme.onErrorContainer),
    };

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
                    request.campaignTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    request.status.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Charity: ${request.charityName}'),
            const SizedBox(height: 4),
            Text('Requested: ${request.requestedAt.toLocal()}'),
            if (request.message != null) ...[
              const SizedBox(height: 6),
              Text(request.message!),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: null,
                    child: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: null,
                    child: const Text('Update Status'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
