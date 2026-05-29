import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/charities/presentation/providers/charity_public_profile_provider.dart';
import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/features/bank_accounts/presentation/providers/bank_account_repository_provider.dart';
import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';
import 'package:charity_managment/models/user_role.dart';

class CharityPublicProfileScreen extends ConsumerWidget {
  const CharityPublicProfileScreen({
    super.key,
    required this.charityId,
  });

  final String charityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profileAsync = ref.watch(charityPublicProfileProvider(charityId));
    final myProfileAsync = ref.watch(myCharityProfileProvider);
    final followController = ref.read(campaignFollowProvider.notifier);
    final followedIds = ref.watch(campaignFollowProvider).valueOrNull ?? <String>{};

    return AppScaffold(
      title: 'Charity Profile',
      drawer: const AppNavigationDrawer(),
      showNotificationAction: auth.isAuthenticated,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load charity profile',
          subtitle: error.toString(),
        ),
        data: (details) {
          if (details == null) {
            return const EmptyState(
              title: 'Charity not found',
              subtitle: 'This charity profile is no longer available.',
            );
          }

          final profile = details.profile;
          final stats = details.stats;
          final campaigns = details.campaigns;
          final myProfile = myProfileAsync.valueOrNull;
          final isOwnCharityProfile =
              auth.isAuthenticated &&
              auth.user?.role == UserRole.charityOrganization &&
              myProfile != null &&
              myProfile.id == profile.id;

          return ListView(
            children: [
              _HeaderCard(profile: profile),
              const SizedBox(height: 16),
              _StatsRow(stats: stats),
              const SizedBox(height: 20),
              if (isOwnCharityProfile) ...[
                _BankAccountsSection(),
                const SizedBox(height: 16),
              ],
              Text('Active campaigns', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (campaigns.isEmpty)
                const EmptyState(
                  title: 'No campaigns yet',
                  subtitle: 'This charity has not published any campaigns yet.',
                )
              else
                Column(
                  children: [
                    for (final campaign in campaigns) ...[
                      CampaignCard(
                        campaign: campaign,
                        isFollowed: followedIds.contains(campaign.id),
                        onTap: () => context.go(
                          AppRoutes.campaignDetail(campaign.id),
                        ),
                        onFollowTap: () => _handleFollowTap(
                          context,
                          auth.isAuthenticated,
                          followController,
                          campaign.id,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleFollowTap(
    BuildContext context,
    bool isAuthenticated,
    CampaignFollowController controller,
    String campaignId,
  ) {
    if (!isAuthenticated) {
      _promptSignIn(context);
      return;
    }
    controller.toggleFollow(campaignId);
  }

  void _promptSignIn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign in to follow campaigns.'),
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
      ),
    );
  }
}

class _BankAccountsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountsProvider);
    final mutationState = ref.watch(bankAccountMutationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bank accounts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: mutationState.isLoading
                  ? null
                  : () => _showBankAccountFormDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Unable to load bank accounts: $error'),
          ),
          data: (accounts) {
            if (accounts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No bank accounts yet. Add one to receive campaign funds.'),
              );
            }

            return Column(
              children: [
                for (final account in accounts) ...[
                  _InlineBankAccountCard(account: account),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InlineBankAccountCard extends ConsumerWidget {
  const _InlineBankAccountCard({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutationState = ref.watch(bankAccountMutationProvider);
    final isBusy = mutationState.isLoading;

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
                    account.bankName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (account.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Primary',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Holder: ${account.accountHolder}'),
            const SizedBox(height: 4),
            Text('Number: ${_masked(account.accountNumber)}'),
            const SizedBox(height: 4),
            Text('Type: ${account.type.toUpperCase()}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => _showBankAccountFormDialog(
                            context,
                            ref,
                            initial: account,
                          ),
                  child: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: isBusy || account.isPrimary
                      ? null
                      : () async {
                          await ref.read(bankAccountMutationProvider.notifier).setPrimary(account.id);
                          final state = ref.read(bankAccountMutationProvider);
                          if (!context.mounted) return;
                          if (state.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error.toString())),
                            );
                          }
                        },
                  child: const Text('Set primary'),
                ),
                TextButton(
                  onPressed: isBusy
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete bank account'),
                              content: const Text(
                                'Are you sure you want to delete this bank account?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;
                          await ref.read(bankAccountMutationProvider.notifier).remove(account.id);
                          final state = ref.read(bankAccountMutationProvider);
                          if (!context.mounted) return;
                          if (state.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error.toString())),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bank account deleted.')),
                            );
                          }
                        },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _masked(String raw) {
    if (raw.length <= 4) return raw;
    final last4 = raw.substring(raw.length - 4);
    return '•••• •••• $last4';
  }
}

Future<void> _showBankAccountFormDialog(
  BuildContext context,
  WidgetRef ref, {
  BankAccount? initial,
}) async {
  final formKey = GlobalKey<FormState>();
  final bankNameController = TextEditingController(text: initial?.bankName ?? '');
  final holderController = TextEditingController(text: initial?.accountHolder ?? '');
  final numberController = TextEditingController(text: initial?.accountNumber ?? '');
  var accountType = initial?.type.toUpperCase() == 'BUSINESS' ? 'BUSINESS' : 'PERSONAL';
  var isPrimary = initial?.isPrimary ?? false;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(initial == null ? 'Add bank account' : 'Edit bank account'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Bank name is required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: holderController,
                      decoration: const InputDecoration(labelText: 'Account holder'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Account holder is required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Account number'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Account number is required' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: accountType,
                      items: const [
                        DropdownMenuItem(value: 'PERSONAL', child: Text('Personal')),
                        DropdownMenuItem(value: 'BUSINESS', child: Text('Business')),
                      ],
                      decoration: const InputDecoration(labelText: 'Account type'),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => accountType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: isPrimary,
                      onChanged: (value) => setState(() => isPrimary = value),
                      title: const Text('Set as primary'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != true) return;

  final notifier = ref.read(bankAccountMutationProvider.notifier);
  if (initial == null) {
    await notifier.create(
      bankName: bankNameController.text.trim(),
      accountHolder: holderController.text.trim(),
      accountNumber: numberController.text.trim(),
      type: accountType,
      isPrimary: isPrimary,
    );
  } else {
    await notifier.update(
      accountId: initial.id,
      bankName: bankNameController.text.trim(),
      accountHolder: holderController.text.trim(),
      accountNumber: numberController.text.trim(),
      type: accountType,
      isPrimary: isPrimary,
    );
  }

  final state = ref.read(bankAccountMutationProvider);
  if (context.mounted) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(initial == null ? 'Bank account added.' : 'Bank account updated.'),
        ),
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final CharityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.favorite, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.organizationName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (profile.isVerified)
                        Text(
                          'Verified charity',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: colorScheme.primary),
                        )
                      else
                        Text(
                          'Verification pending',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: colorScheme.tertiary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.description != null)
              Text(
                profile.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (profile.description != null) const SizedBox(height: 12),
            _InfoRow(label: 'Phone', value: profile.phone ?? 'Not provided'),
            _InfoRow(label: 'Website', value: profile.website ?? 'Not provided'),
            _InfoRow(label: 'Address', value: profile.address ?? 'Not provided'),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final CharityStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(
          label: 'Campaigns',
          value: stats.totalCampaigns.toString(),
          textTheme: textTheme,
        ),
        _StatTile(
          label: 'Active',
          value: stats.activeCampaigns.toString(),
          textTheme: textTheme,
        ),
        _StatTile(
          label: 'Raised',
          value: stats.totalRaised.toStringAsFixed(0),
          textTheme: textTheme,
        ),
        _StatTile(
          label: 'Donors',
          value: stats.totalDonors.toString(),
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
