import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/dashed_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/features/bank_accounts/presentation/providers/bank_account_repository_provider.dart';
import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/features/profile/presentation/providers/current_profile_provider.dart';
import 'package:charity_managment/features/profile/presentation/providers/profile_update_provider.dart';
import 'package:charity_managment/features/profile/presentation/utils/profile_validators.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/async_value_view.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.initiallyEditing = false});

  final bool initiallyEditing;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  final _organizationNameController = TextEditingController();
  final _charityDescriptionController = TextEditingController();
  final _charityPhoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  final _facebookController = TextEditingController();
  final _telegramController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _tiktokController = TextEditingController();

  final _documentPathController = TextEditingController();
  final _logoPathController = TextEditingController();

  Uint8List? _logoBytes;
  bool _isEditing = false;
  bool _initialized = false;
  String _profileSignature = '';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initiallyEditing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _organizationNameController.dispose();
    _charityDescriptionController.dispose();
    _charityPhoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _telegramController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    _documentPathController.dispose();
    _logoPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final updateState = ref.watch(profileUpdateProvider);

    return AppScaffold(
      title: 'Profile',
      drawer: const AppNavigationDrawer(),
      actions: [
        if (_isEditing)
          IconButton(
            tooltip: 'Cancel',
            icon: const Icon(Icons.close),
            onPressed: () {
              profileAsync.valueOrNull?.let(_cancelEditing);
            },
          )
        else
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              profileAsync.valueOrNull?.let(_startEditing);
            },
          ),
        if (_isEditing)
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.check),
            onPressed: updateState.isLoading
                ? null
                : () async {
                    final profile = profileAsync.valueOrNull;
                    if (profile != null) {
                      await _saveProfile(profile);
                    }
                  },
          ),
      ],
      body: AsyncValueView(
        value: profileAsync,
        data: (profile) {
          final signature = _profileSignatureFor(profile);
          if (!_initialized || signature != _profileSignature) {
            _seedControllers(profile);
            _initialized = true;
            _profileSignature = signature;
          }

          final isCharity = profile.user.role == ProfileRole.charity;
          final bankAccountsAsync = ref.watch(bankAccountsProvider);

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(profile: profile),
                  const SizedBox(height: AppTheme.spacing16),
                  _PersonalInfoCard(
                    profile: profile,
                    isEditing: _isEditing,
                    nameController: _nameController,
                    phoneController: _phoneController,
                    bioController: _bioController,
                  ),
                  if (isCharity) ...[
                    const SizedBox(height: AppTheme.spacing16),
                    _CharityInfoCard(
                      profile: profile,
                      isEditing: _isEditing,
                      organizationNameController: _organizationNameController,
                      charityDescriptionController: _charityDescriptionController,
                      charityPhoneController: _charityPhoneController,
                      websiteController: _websiteController,
                      addressController: _addressController,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    _CharitySocialLinksCard(
                      profile: profile,
                      isEditing: _isEditing,
                      facebookController: _facebookController,
                      telegramController: _telegramController,
                      instagramController: _instagramController,
                      twitterController: _twitterController,
                      youtubeController: _youtubeController,
                      tiktokController: _tiktokController,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    _BankAccountsSummaryCard(
                      accountsAsync: bankAccountsAsync,
                      onManage: () => context.go(AppRoutes.bankAccounts),
                    ),
                    if (_isEditing && profile.charityProfile == null) ...[
                      const SizedBox(height: AppTheme.spacing16),
                      _CharityCreationUploadsCard(
                        documentPathController: _documentPathController,
                        logoPathController: _logoPathController,
                        logoBytes: _logoBytes,
                        onPickDocument: _pickDocument,
                        onPickLogo: _pickLogo,
                      ),
                    ],
                  ],
                  if (updateState.hasError) ...[
                    const SizedBox(height: AppTheme.spacing16),
                    _ErrorBanner(message: updateState.error.toString()),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startEditing(ProfileData profile) {
    setState(() {
      _seedControllers(profile);
      _isEditing = true;
    });
  }

  void _cancelEditing(ProfileData profile) {
    setState(() {
      _seedControllers(profile);
      _isEditing = false;
    });
  }

  void _seedControllers(ProfileData profile) {
    _nameController.text = profile.user.name;
    _phoneController.text = profile.user.phone ?? '';
    _bioController.text = profile.user.bio ?? '';

    final charity = profile.charityProfile;
    _organizationNameController.text = charity?.organizationName ?? '';
    _charityDescriptionController.text = charity?.description ?? '';
    _charityPhoneController.text = charity?.phone ?? '';
    _websiteController.text = charity?.website ?? '';
    _addressController.text = charity?.address ?? '';

    _facebookController.text = charity?.socialFacebook ?? '';
    _telegramController.text = charity?.socialTelegram ?? '';
    _instagramController.text = charity?.socialInstagram ?? '';
    _twitterController.text = charity?.socialTwitter ?? '';
    _youtubeController.text = charity?.socialYoutube ?? '';
    _tiktokController.text = charity?.socialTiktok ?? '';

    _documentPathController.text = charity?.documentUrl ?? '';
    _logoPathController.text = '';
    _logoBytes = null;
  }

  String _profileSignatureFor(ProfileData profile) {
    final charity = profile.charityProfile;
    return [
      profile.user.name,
      profile.user.email,
      profile.user.role.value,
      profile.user.bio ?? '',
      profile.user.phone ?? '',
      charity?.organizationName ?? '',
      charity?.description ?? '',
      charity?.phone ?? '',
      charity?.address ?? '',
      charity?.website ?? '',
      charity?.socialFacebook ?? '',
      charity?.socialTelegram ?? '',
      charity?.socialInstagram ?? '',
      charity?.socialTwitter ?? '',
      charity?.socialYoutube ?? '',
      charity?.socialTiktok ?? '',
      charity?.documentUrl ?? '',
    ].join('|');
  }

  Future<void> _saveProfile(ProfileData profile) async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(profileUpdateProvider.notifier);

    if (profile.user.role == ProfileRole.charity) {
      if (profile.charityProfile == null) {
        final updatedUser = await notifier.updateUserProfile(
          UserProfileUpdateInput(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
          ),
        );

        if (updatedUser == null) return;

        if (_documentPathController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification document is required.')),
          );
          return;
        }

        final updated = await notifier.createCharityProfile(
          organizationName: _organizationNameController.text.trim(),
          description: _charityDescriptionController.text.trim(),
          documentPath: _documentPathController.text.trim(),
          logoPath: _logoPathController.text.trim().isEmpty
              ? null
              : _logoPathController.text.trim(),
          phone: _charityPhoneController.text.trim().isEmpty
              ? null
              : _charityPhoneController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
        );

        if (updated != null && mounted) {
          setState(() {
            _seedControllers(updated);
            _isEditing = false;
            _profileSignature = _profileSignatureFor(updated);
          });
        }
        return;
      }

      final updatedUser = await notifier.updateUserProfile(
        UserProfileUpdateInput(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
        ),
      );

      if (updatedUser == null) return;

      final updated = await notifier.updateCharityProfile(
        CharityProfileUpdateInput(
          organizationName: _organizationNameController.text.trim(),
          description: _charityDescriptionController.text.trim().isEmpty
              ? null
              : _charityDescriptionController.text.trim(),
          phone: _charityPhoneController.text.trim().isEmpty
              ? null
              : _charityPhoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          socialFacebook: _facebookController.text.trim().isEmpty
              ? null
              : _facebookController.text.trim(),
          socialTelegram: _telegramController.text.trim().isEmpty
              ? null
              : _telegramController.text.trim(),
          socialInstagram: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          socialTwitter: _twitterController.text.trim().isEmpty
              ? null
              : _twitterController.text.trim(),
          socialYoutube: _youtubeController.text.trim().isEmpty
              ? null
              : _youtubeController.text.trim(),
          socialTiktok: _tiktokController.text.trim().isEmpty
              ? null
              : _tiktokController.text.trim(),
        ),
      );

      if (updated != null && mounted) {
        setState(() {
          _seedControllers(updated);
          _isEditing = false;
          _profileSignature = _profileSignatureFor(updated);
        });
      }
      return;
    }

    final updated = await notifier.updateUserProfile(
      UserProfileUpdateInput(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _seedControllers(updated);
        _isEditing = false;
        _profileSignature = _profileSignatureFor(updated);
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _documentPathController.text = path);
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(withData: kIsWeb);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() {
        _logoPathController.text = path;
        _logoBytes = result?.files.single.bytes;
      });
    } else if (kIsWeb && result?.files.single.bytes != null) {
      setState(() {
        _logoPathController.text = result?.files.single.name ?? '';
        _logoBytes = result?.files.single.bytes;
      });
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              profile.user.name.isNotEmpty ? profile.user.name[0].toUpperCase() : '?',
              style: AppTextStyles.display.copyWith(
                color: colorScheme.primary,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(profile.user.name, style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            profile.user.email,
            style: AppTextStyles.body.copyWith(color: AppColors.textBody),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppTheme.borderRadiusPill,
            ),
            child: Text(
              profile.user.role.label,
              style: AppTextStyles.micro.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({
    required this.profile,
    required this.isEditing,
    required this.nameController,
    required this.phoneController,
    required this.bioController,
  });

  final ProfileData profile;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal info', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing16),
          if (isEditing) ...[
            FormInput(
              label: profile.user.role == ProfileRole.charity ? 'Name' : 'Full name',
              controller: nameController,
              hint: profile.user.role == ProfileRole.charity ? 'Enter name' : 'Enter your name',
              validator: (value) => ProfileValidators.requiredText(
                value,
                profile.user.role == ProfileRole.charity ? 'Name' : 'Full name',
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Phone',
              controller: phoneController,
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
              validator: ProfileValidators.phone,
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Bio',
              controller: bioController,
              hint: 'Tell people about yourself',
              maxLines: 3,
            ),
          ] else ...[
            _ReadOnlyField(label: 'Bio', value: profile.user.bio),
            const SizedBox(height: AppTheme.spacing12),
            _ReadOnlyField(label: 'Phone', value: profile.user.phone),
          ],
        ],
      ),
    );
  }
}

class _CharityInfoCard extends StatelessWidget {
  const _CharityInfoCard({
    required this.profile,
    required this.isEditing,
    required this.organizationNameController,
    required this.charityDescriptionController,
    required this.charityPhoneController,
    required this.websiteController,
    required this.addressController,
  });

  final ProfileData profile;
  final bool isEditing;
  final TextEditingController organizationNameController;
  final TextEditingController charityDescriptionController;
  final TextEditingController charityPhoneController;
  final TextEditingController websiteController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    final charity = profile.charityProfile;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Charity info', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing16),
          if (isEditing) ...[
            FormInput(
              label: 'Organization name',
              controller: organizationNameController,
              hint: 'Enter organization name',
              validator: (value) => ProfileValidators.requiredText(value, 'Organization name'),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Description',
              controller: charityDescriptionController,
              hint: 'Describe your organization...',
              maxLines: 3,
              validator: (value) => ProfileValidators.requiredText(value, 'Description'),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Charity phone',
              controller: charityPhoneController,
              hint: 'Contact number',
              keyboardType: TextInputType.phone,
              validator: ProfileValidators.phone,
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Website',
              controller: websiteController,
              hint: 'https://example.org',
              keyboardType: TextInputType.url,
              validator: ProfileValidators.website,
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Address',
              controller: addressController,
              hint: 'Physical address',
              maxLines: 2,
            ),
          ] else ...[
            _ReadOnlyField(label: 'Organization', value: charity?.organizationName),
            const SizedBox(height: AppTheme.spacing12),
            _ReadOnlyField(label: 'Description', value: charity?.description),
            const SizedBox(height: AppTheme.spacing12),
            _ReadOnlyField(label: 'Charity phone', value: charity?.phone),
            const SizedBox(height: AppTheme.spacing12),
            _ReadOnlyField(label: 'Website', value: charity?.website),
            const SizedBox(height: AppTheme.spacing12),
            _ReadOnlyField(label: 'Address', value: charity?.address),
          ],
        ],
      ),
    );
  }
}

class _CharitySocialLinksCard extends StatelessWidget {
  const _CharitySocialLinksCard({
    required this.profile,
    required this.isEditing,
    required this.facebookController,
    required this.telegramController,
    required this.instagramController,
    required this.twitterController,
    required this.youtubeController,
    required this.tiktokController,
  });

  final ProfileData profile;
  final bool isEditing;
  final TextEditingController facebookController;
  final TextEditingController telegramController;
  final TextEditingController instagramController;
  final TextEditingController twitterController;
  final TextEditingController youtubeController;
  final TextEditingController tiktokController;

  @override
  Widget build(BuildContext context) {
    final charity = profile.charityProfile;
    final links = <_SocialLinkData>[
      _SocialLinkData(key: 'Facebook', value: charity?.socialFacebook ?? '', color: const Color(0xFF1877F2), icon: Icons.facebook),
      _SocialLinkData(key: 'Telegram', value: charity?.socialTelegram ?? '', color: const Color(0xFF229ED9), icon: Icons.send_outlined),
      _SocialLinkData(key: 'Instagram', value: charity?.socialInstagram ?? '', color: const Color(0xFFE4405F), icon: Icons.camera_alt_outlined),
      _SocialLinkData(key: 'Twitter', value: charity?.socialTwitter ?? '', color: const Color(0xFF111827), icon: Icons.alternate_email),
      _SocialLinkData(key: 'YouTube', value: charity?.socialYoutube ?? '', color: const Color(0xFFFF0000), icon: Icons.play_circle_outline),
      _SocialLinkData(key: 'TikTok', value: charity?.socialTiktok ?? '', color: Colors.black, icon: Icons.music_note_outlined),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Social links', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing16),
          if (isEditing) ...[
            FormInput(
              label: 'Facebook',
              controller: facebookController,
              hint: 'facebook.com/...',
              prefixIcon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Telegram',
              controller: telegramController,
              hint: 't.me/...',
              prefixIcon: const Icon(Icons.send_outlined, color: Color(0xFF229ED9)),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Instagram',
              controller: instagramController,
              hint: 'instagram.com/...',
              prefixIcon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFE4405F)),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Twitter',
              controller: twitterController,
              hint: 'twitter.com/...',
              prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF111827)),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'YouTube',
              controller: youtubeController,
              hint: 'youtube.com/...',
              prefixIcon: const Icon(Icons.play_circle_outline, color: Color(0xFFFF0000)),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'TikTok',
              controller: tiktokController,
              hint: 'tiktok.com/@...',
              prefixIcon: const Icon(Icons.music_note_outlined, color: Colors.black),
            ),
          ] else ...[
            if (links.any((link) => link.value.trim().isNotEmpty))
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final link in links)
                    if (link.value.trim().isNotEmpty)
                      _SocialChip(link: link),
                ],
              )
            else
              const Text('No social links added yet.'),
          ],
        ],
      ),
    );
  }
}

class _BankAccountsSummaryCard extends StatelessWidget {
  const _BankAccountsSummaryCard({
    required this.accountsAsync,
    required this.onManage,
  });

  final AsyncValue<List<BankAccount>> accountsAsync;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Bank accounts', style: AppTextStyles.title)),
              OutlinedButton.icon(
                onPressed: onManage,
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          accountsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(
              'Unable to load bank accounts: $error',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
            data: (accounts) {
              if (accounts.isEmpty) {
                return const Text('No bank accounts added yet.');
              }

              return Column(
                children: [
                  for (final account in accounts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BankAccountSummaryTile(account: account),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BankAccountSummaryTile extends StatelessWidget {
  const _BankAccountSummaryTile({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context) {
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
            '•••• ${account.accountNumber.length > 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _CharityCreationUploadsCard extends StatelessWidget {
  const _CharityCreationUploadsCard({
    required this.documentPathController,
    required this.logoPathController,
    required this.logoBytes,
    required this.onPickDocument,
    required this.onPickLogo,
  });

  final TextEditingController documentPathController;
  final TextEditingController logoPathController;
  final Uint8List? logoBytes;
  final VoidCallback onPickDocument;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create charity profile', style: AppTextStyles.title),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'A verification document is required before the charity profile can be created.',
            style: AppTextStyles.body.copyWith(color: AppColors.textBody),
          ),
          const SizedBox(height: AppTheme.spacing16),
          _UploadTile(
            label: 'Verification document',
            value: documentPathController.text,
            onTap: onPickDocument,
            helpText: 'PDF, JPG or PNG',
          ),
          const SizedBox(height: AppTheme.spacing16),
          _UploadTile(
            label: 'Logo image',
            value: logoPathController.text,
            onTap: onPickLogo,
            helpText: 'Optional',
            previewBytes: logoBytes,
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.helpText,
    this.previewBytes,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String helpText;
  final Uint8List? previewBytes;

  @override
  Widget build(BuildContext context) {
    final fileName = value.isEmpty ? 'Tap to upload' : value.split('/').last;

    return GestureDetector(
      onTap: onTap,
      child: DashedCard(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 30, color: AppColors.primary),
              const SizedBox(height: AppTheme.spacing12),
              Text(label, style: AppTextStyles.label),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                fileName,
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              if (previewBytes != null) ...[
                const SizedBox(height: AppTheme.spacing12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    previewBytes!,
                    height: 88,
                    width: 88,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacing4),
              Text(helpText, style: AppTextStyles.micro),
            ],
          ),
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
    return Chip(
      avatar: Icon(link.icon, size: 18, color: link.color),
      label: Text(link.key),
      side: BorderSide(color: link.color.withValues(alpha: 0.18)),
      backgroundColor: link.color.withValues(alpha: 0.06),
      labelStyle: AppTextStyles.micro.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro.copyWith(color: AppColors.textBody)),
        const SizedBox(height: 4),
        Text(
          (value == null || value!.trim().isEmpty) ? 'Not provided' : value!,
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _SocialLinkData {
  const _SocialLinkData({
    required this.key,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String key;
  final String value;
  final Color color;
  final IconData icon;
}

extension _NullableLet<T> on T? {
  void let(void Function(T value) block) {
    final value = this;
    if (value != null) block(value);
  }
}
