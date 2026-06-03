import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/charities/presentation/providers/charity_public_profile_provider.dart';
import 'package:charity_managment/features/charities/domain/charity_public_profile.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_follow_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/models/charity_stats.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(profile: profile),
              const SizedBox(height: 20),
              _StatsRow(stats: stats),
              const SizedBox(height: 24),
              _CharityInfoCard(profile: profile),
              const SizedBox(height: 20),
              _CharitySocialLinksCard(profile: profile),
              if (profile.bankAccounts.isNotEmpty) ...[
                const SizedBox(height: 20),
                _BankAccountsSection(accounts: profile.bankAccounts),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Active Campaigns',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final CharityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final isVerified = profile.isVerified;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoAvatar(logo: profile.logo, name: profile.organizationName),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.organizationName, style: AppTextStyles.title),
                    const SizedBox(height: AppTheme.spacing4),
                    _StatusBadge(profile: profile),
                    if (profile.verifiedAt != null) ...[
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Verified on ${_formatDate(profile.verifiedAt!)}',
                        style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (profile.description != null && profile.description!.trim().isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing12),
            Text(profile.description!, style: AppTextStyles.body),
          ],
          const SizedBox(height: AppTheme.spacing16),
          _DetailRow(label: 'Phone', value: profile.phone),
          _DetailRow(label: 'Website', value: profile.website),
          _DetailRow(label: 'Address', value: profile.address),
          if (!isVerified) ...[
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Verification pending',
              style: AppTextStyles.micro.copyWith(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CharityInfoCard extends StatelessWidget {
  const _CharityInfoCard({required this.profile});

  final CharityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Charity information', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing16),
          _DetailRow(label: 'Phone', value: profile.phone),
          _DetailRow(label: 'Website', value: profile.website),
          _DetailRow(label: 'Address', value: profile.address),
        ],
      ),
    );
  }
}

class _CharitySocialLinksCard extends StatelessWidget {
  const _CharitySocialLinksCard({required this.profile});

  final CharityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final links = <_SocialLinkData>[
      _SocialLinkData(
        label: 'Facebook',
        value: profile.socialFacebook ?? '',
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
      ),
      _SocialLinkData(
        label: 'Telegram',
        value: profile.socialTelegram ?? '',
        icon: Icons.send_outlined,
        color: const Color(0xFF229ED9),
      ),
      _SocialLinkData(
        label: 'Instagram',
        value: profile.socialInstagram ?? '',
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFFE4405F),
      ),
      _SocialLinkData(
        label: 'Twitter',
        value: profile.socialTwitter ?? '',
        icon: Icons.alternate_email,
        color: const Color(0xFF111827),
      ),
      _SocialLinkData(
        label: 'YouTube',
        value: profile.socialYoutube ?? '',
        icon: Icons.play_circle_outline,
        color: const Color(0xFFFF0000),
      ),
      _SocialLinkData(
        label: 'TikTok',
        value: profile.socialTiktok ?? '',
        icon: Icons.music_note_outlined,
        color: Colors.black,
      ),
    ];

    final activeLinks = links.where((link) => link.value.trim().isNotEmpty).toList(growable: false);

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Social links', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing16),
          if (activeLinks.isEmpty)
            Text(
              'No social links added yet.',
              style: AppTextStyles.body.copyWith(color: AppColors.textBody),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final link in activeLinks) _SocialChip(link: link)],
            ),
        ],
      ),
    );
  }
}

class _BankAccountsSection extends StatelessWidget {
  const _BankAccountsSection({required this.accounts});

  final List<BankAccount> accounts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank accounts', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing16),
          if (accounts.isEmpty)
            Text(
              'No bank accounts added yet.',
              style: AppTextStyles.body.copyWith(color: AppColors.textBody),
            )
          else
            Column(
              children: [
                for (final account in accounts) ...[
                  _PublicBankAccountCard(account: account),
                  const SizedBox(height: AppTheme.spacing12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PublicBankAccountCard extends StatelessWidget {
  const _PublicBankAccountCard({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masked = _masked(account.accountNumber);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(account.bankName, style: AppTextStyles.label),
              ),
              if (account.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Primary',
                    style: AppTextStyles.micro.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            account.accountHolder,
            style: AppTextStyles.body.copyWith(color: AppColors.textBody),
          ),
          const SizedBox(height: 4),
          Text(
            masked,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  account.type.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: account.accountNumber));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied ${account.bankName} account number.')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = (value == null || value!.trim().isEmpty) ? 'Not provided' : value!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
            ),
          ),
          Expanded(
            child: Text(display, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.profile});

  final CharityPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final isApproved = profile.status?.toUpperCase() == 'APPROVED' || profile.isVerified;
    final color = isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final label = isApproved ? 'Verified' : (profile.status ?? 'Pending verification');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.borderRadiusPill,
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  const _LogoAvatar({required this.logo, required this.name});

  final String? logo;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final hasNetworkLogo = logo != null && logo!.trim().startsWith('http');

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppTheme.borderRadiusMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasNetworkLogo
          ? Image.network(
              logo!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  initial,
                  style: AppTextStyles.title.copyWith(color: AppColors.primary),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: AppTextStyles.title.copyWith(color: AppColors.primary),
              ),
            ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.link});

  final _SocialLinkData link;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppTheme.borderRadiusPill,
        onTap: () async {
          final url = _normalizeUrl(link.value);
          final uri = Uri.tryParse(url);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: link.color.withValues(alpha: 0.06),
            borderRadius: AppTheme.borderRadiusPill,
            border: Border.all(color: link.color.withValues(alpha: 0.16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(link.icon, size: 18, color: link.color),
              const SizedBox(width: 8),
              Text(
                link.label,
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.textBody.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLinkData {
  const _SocialLinkData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

String _masked(String raw) {
  if (raw.length <= 4) return raw;
  final last4 = raw.substring(raw.length - 4);
  return '•••• •••• $last4';
}

String _formatDate(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _normalizeUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final CharityStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
      crossAxisSpacing: AppTheme.spacing12,
      mainAxisSpacing: AppTheme.spacing12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _StatTile(
          label: 'Campaigns',
          value: stats.totalCampaigns.toString(),
          icon: Icons.campaign_outlined,
          tint: const Color(0xFF3B82F6),
        ),
        _StatTile(
          label: 'Active',
          value: stats.activeCampaigns.toString(),
          icon: Icons.play_circle_outline,
          tint: const Color(0xFF10B981),
        ),
        _StatTile(
          label: 'Raised',
          value: stats.totalRaised.toStringAsFixed(0),
          icon: Icons.savings_outlined,
          tint: const Color(0xFFF59E0B),
        ),
        _StatTile(
          label: 'Donors',
          value: stats.totalDonors.toString(),
          icon: Icons.groups_outlined,
          tint: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: AppTheme.borderRadiusMd,
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              color: tint,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.micro.copyWith(
              color: AppColors.textBody,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
