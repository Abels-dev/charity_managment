import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/features/campaign_requests/domain/campaign_request.dart';
import 'package:charity_managment/features/campaign_requests/presentation/providers/campaign_requests_provider.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class CampaignRequestsScreen extends ConsumerStatefulWidget {
  const CampaignRequestsScreen({super.key});

  @override
  ConsumerState<CampaignRequestsScreen> createState() => _CampaignRequestsScreenState();
}

class _CampaignRequestsScreenState extends ConsumerState<CampaignRequestsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  int _page = 1;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _refreshPage(int page) async {
    ref.invalidate(campaignRequestsProvider(page));
    await ref.read(campaignRequestsProvider(page).future);
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(campaignRequestRepositoryProvider);
    final reason = _reasonController.text.trim();

    try {
      await repository.submitCampaignRequest(reason: reason);
      _reasonController.clear();

      setState(() {
        _page = 1;
      });
      await _refreshPage(1);

      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Campaign request submitted.')));
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Unable to submit request: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(campaignRequestsProvider(_page));

    return AppScaffold(
      title: 'Campaign Requests',
      drawer: const AppNavigationDrawer(),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load campaign requests',
          subtitle: error.toString(),
        ),
        data: (response) {
          return RefreshIndicator(
            onRefresh: () => _refreshPage(_page),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderCard(summary: response.summary),
                const SizedBox(height: 16),
                _SummaryGrid(summary: response.summary),
                const SizedBox(height: 16),
                _SubmissionCard(
                  formKey: _formKey,
                  reasonController: _reasonController,
                  onSubmit: _submitRequest,
                  summary: response.summary,
                ),
                const SizedBox(height: 16),
                _HistoryHeader(total: response.total),
                const SizedBox(height: 12),
                if (response.items.isEmpty)
                  const EmptyState(
                    title: 'No campaign requests yet',
                    subtitle: 'Submit a request to see it appear here.',
                  )
                else
                  ...response.items.map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RequestCard(request: request),
                    ),
                  ),
                if (response.totalPages > 1) ...[
                  const SizedBox(height: 8),
                  _PaginationBar(
                    page: response.page,
                    totalPages: response.totalPages,
                    onPrevious: _page > 1
                        ? () {
                            setState(() {
                              _page -= 1;
                            });
                          }
                        : null,
                    onNext: _page < response.totalPages
                        ? () {
                            setState(() {
                              _page += 1;
                            });
                          }
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.summary});

  final CampaignRequestSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request a new campaign',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Share why you need a new campaign and track your request history in one place.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(label: 'Monthly limit: ${summary.monthlyLimit}'),
              _HeaderChip(label: 'Pending: ${summary.pendingRequestCount}'),
              _HeaderChip(label: 'Approved allowance: ${summary.approvedAllowanceCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: theme.textTheme.labelLarge),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final CampaignRequestSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = <_SummaryItem>[
      _SummaryItem(label: 'This month', value: summary.currentMonthCampaignCount.toString(), icon: Icons.event_note_outlined),
      _SummaryItem(label: 'Active', value: summary.activeCampaignCount.toString(), icon: Icons.campaign_outlined),
      _SummaryItem(label: 'Pending', value: summary.pendingRequestCount.toString(), icon: Icons.hourglass_top_outlined),
      _SummaryItem(label: 'Approved allowance', value: summary.approvedAllowanceCount.toString(), icon: Icons.verified_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 800 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth >= 800 ? 1.75 : 1.35,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.formKey,
    required this.reasonController,
    required this.onSubmit,
    required this.summary,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final VoidCallback onSubmit;
  final CampaignRequestSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit a request', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Tell us what you need the campaign for and why it should be reviewed.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FormInput(
              label: 'Reason',
              hint: 'Describe the campaign purpose and goal',
              controller: reasonController,
              maxLines: 4,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Please provide a reason for the request.';
                }
                if ((value ?? '').trim().length < 20) {
                  return 'Please add a bit more detail.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text('Request history', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Text('$total total', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final CampaignRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg, icon) = switch (request.status) {
      CampaignRequestStatus.pending => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          Icons.hourglass_top_outlined,
        ),
      CampaignRequestStatus.approved => (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.check_circle_outline,
        ),
      CampaignRequestStatus.rejected => (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
          Icons.cancel_outlined,
        ),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.reason, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Requested on ${_formatDate(request.requestedAt)}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                    Text(request.status.label, style: theme.textTheme.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Charity', value: request.charityName),
          if (request.reviewedByName != null) ...[
            const SizedBox(height: 8),
            _InfoRow(label: 'Reviewed by', value: request.reviewedByName!),
          ],
          if (request.message != null && request.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(request.message!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 12),
        Text('Page $page of $totalPages'),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
