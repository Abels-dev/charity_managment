import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/presentation/providers/current_profile_provider.dart';
import 'package:charity_managment/features/profile/presentation/providers/profile_update_provider.dart';

import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/features/bank_accounts/presentation/providers/bank_account_repository_provider.dart';
import 'package:charity_managment/features/bank_accounts/presentation/screens/bank_accounts_screen.dart' show showBankAccountFormDialog;

import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/async_value_view.dart';

import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/core/widgets/dashed_card.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return AppScaffold(
      title: 'Profile',
      drawer: const AppNavigationDrawer(),
      body: AsyncValueView(
        value: profileAsync,
        data: (profile) {
          if (profile.user.role == ProfileRole.charity) {
            return _CharityProfileView(profile: profile);
          } else {
            return _DonorProfileView(profile: profile);
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Charity Profile View
// ---------------------------------------------------------------------------

class _CharityProfileView extends ConsumerStatefulWidget {
  const _CharityProfileView({required this.profile});
  final ProfileData profile;

  @override
  ConsumerState<_CharityProfileView> createState() => _CharityProfileViewState();
}

class _CharityProfileViewState extends ConsumerState<_CharityProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoController = TextEditingController();
  Uint8List? _logoBytes;
  
  final _facebookController = TextEditingController();
  final _telegramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _tiktokController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _logoController.dispose();
    _facebookController.dispose();
    _telegramController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(withData: kIsWeb);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() {
        _logoController.text = path;
        _logoBytes = result?.files.single.bytes;
      });
    } else if (kIsWeb && result?.files.single.bytes != null) {
      setState(() {
        _logoController.text = result?.files.single.name ?? '';
        _logoBytes = result?.files.single.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final charity = widget.profile.charityProfile;
      _nameController.text = charity?.organizationName ?? widget.profile.user.name;
      _descriptionController.text = charity?.description ?? '';
      _phoneController.text = charity?.phone ?? '';
      _addressController.text = charity?.address ?? '';
      _websiteController.text = charity?.website ?? '';
      _facebookController.text = charity?.socialFacebook ?? '';
      _telegramController.text = charity?.socialTelegram ?? '';
      _instagramController.text = charity?.socialInstagram ?? '';
      _twitterController.text = charity?.socialTwitter ?? '';
      _youtubeController.text = charity?.socialYoutube ?? '';
      _tiktokController.text = charity?.socialTiktok ?? '';
      _logoController.text = charity?.documentUrl ?? '';
      _initialized = true;
    }

    final updateState = ref.watch(profileUpdateProvider);
    final bankAccountsAsync = ref.watch(bankAccountsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD 1 — Identity
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: DashedCard(
                      isCircle: true,
                      padding: _logoController.text.isNotEmpty ? EdgeInsets.zero : const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: _logoController.text.isNotEmpty
                            ? ClipOval(
                            child: _logoController.text.startsWith('http')
                              ? Image.network(_logoController.text, fit: BoxFit.cover)
                              : _logoBytes != null
                                ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                                : kIsWeb
                                  ? Container(
                                    color: AppColors.primaryBg,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.primary),
                                    )
                                  : Image.file(File(_logoController.text), fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo, size: 28, color: AppColors.primary),
                                  const SizedBox(height: 4),
                                  Text('Logo', style: AppTextStyles.micro),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(_nameController.text.isNotEmpty ? _nameController.text : 'Charity Profile', style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing8),
                  _VerificationBadge(isVerified: widget.profile.user.isVerified),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // CARD 2 — About
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Description',
                    controller: _descriptionController,
                    hint: 'Describe your organization...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Phone',
                    controller: _phoneController,
                    hint: 'Contact number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Address',
                    controller: _addressController,
                    hint: 'Physical address',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Website',
                    controller: _websiteController,
                    hint: 'https://example.org',
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // CARD 3 — Social Links
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Social Links', style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Facebook',
                    controller: _facebookController,
                    hint: 'facebook.com/...',
                    prefixIcon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Telegram',
                    controller: _telegramController,
                    hint: 't.me/...',
                    prefixIcon: const Icon(Icons.send_outlined, color: Color(0xFF229ED9)),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Twitter',
                    controller: _twitterController,
                    hint: 'twitter.com/...',
                    prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Instagram',
                    controller: _instagramController,
                    hint: 'instagram.com/...',
                    prefixIcon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFE4405F)),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'YouTube',
                    controller: _youtubeController,
                    hint: 'youtube.com/...',
                    prefixIcon: const Icon(Icons.play_circle_outline, color: Color(0xFFFF0000)),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'TikTok',
                    controller: _tiktokController,
                    hint: 'tiktok.com/@...',
                    prefixIcon: const Icon(Icons.music_note_outlined, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // CARD 4 — Bank Accounts
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank Accounts', style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing16),
                  bankAccountsAsync.when(
                    data: (accounts) {
                      return Column(
                        children: [
                          if (accounts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text('No bank accounts added yet.', style: AppTextStyles.body),
                            ),
                          for (final account in accounts)
                            _BankAccountTile(account: account),
                          const SizedBox(height: 8),
                          AppButton(
                            text: 'Add Bank Account',
                            type: AppButtonType.secondary,
                            onPressed: () => showBankAccountFormDialog(context, ref),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading accounts: $e', style: AppTextStyles.body.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            if (updateState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                child: Text(
                  updateState.error.toString(),
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),

            AppButton(
              text: 'Save Changes',
              isLoading: updateState.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final notifier = ref.read(profileUpdateProvider.notifier);
                
                if (widget.profile.charityProfile == null) {
                  // Creating Profile
                  await notifier.createCharityProfile(
                    organizationName: _nameController.text.trim(),
                    description: _descriptionController.text.trim(),
                    documentPath: '', // Keeping signature intact
                    logoPath: _logoController.text.trim(),
                    phone: _phoneController.text.trim(),
                    address: _addressController.text.trim(),
                    website: _websiteController.text.trim(),
                  );
                } else {
                  // Updating Profile
                  await notifier.updateCharityProfile(
                    CharityProfileUpdateInput(
                      organizationName: _nameController.text.trim(),
                      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
                      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                      socialFacebook: _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
                      socialTelegram: _telegramController.text.trim().isEmpty ? null : _telegramController.text.trim(),
                      socialInstagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
                      socialTwitter: _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
                      socialYoutube: _youtubeController.text.trim().isEmpty ? null : _youtubeController.text.trim(),
                      socialTiktok: _tiktokController.text.trim().isEmpty ? null : _tiktokController.text.trim(),
                    ),
                  );
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved successfully')),
                  );
                }
              },
            ),
            const SizedBox(height: AppTheme.spacing32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Donor Profile View (from previous redesign)
// ---------------------------------------------------------------------------

class _DonorProfileView extends ConsumerStatefulWidget {
  const _DonorProfileView({required this.profile});
  final ProfileData profile;

  @override
  ConsumerState<_DonorProfileView> createState() => _DonorProfileViewState();
}

class _DonorProfileViewState extends ConsumerState<_DonorProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _imageController = TextEditingController();
  
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _imageController.text = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _nameController.text = widget.profile.user.name;
      _phoneController.text = widget.profile.user.phone ?? '';
      _bioController.text = widget.profile.user.bio ?? '';
      _initialized = true;
    }

    final user = widget.profile.user;
    final updateState = ref.watch(profileUpdateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top AppCard
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryBg,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(user.name, style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(user.email, style: AppTextStyles.body.copyWith(color: const Color(0xFF64748B))),
                  const SizedBox(height: AppTheme.spacing12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppTheme.borderRadiusPill,
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: AppTextStyles.micro.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Impact AppCard
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Impact', style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Followed campaigns',
                          value: widget.profile.followedCampaignsCount.toString(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: _StatTile(
                          label: 'Donations',
                          value: widget.profile.donationCount.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Edit Profile AppCard
            AppCard(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile', style: AppTextStyles.title),
                  const SizedBox(height: AppTheme.spacing24),
                  FormInput(
                    label: 'Full Name',
                    controller: _nameController,
                    hint: 'Enter your full name',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Bio',
                    controller: _bioController,
                    hint: 'Tell us a bit about yourself...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  FormInput(
                    label: 'Phone',
                    controller: _phoneController,
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Text('Profile Image', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: AppTheme.spacing8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: DashedCard(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primary),
                            const SizedBox(height: AppTheme.spacing12),
                            Text(
                              _imageController.text.isEmpty ? 'Tap to upload' : _imageController.text.split('/').last,
                              style: AppTextStyles.label.copyWith(color: AppColors.primary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            if (updateState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                child: Text(
                  updateState.error.toString(),
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),

            AppButton(
              text: 'Save',
              isLoading: updateState.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final notifier = ref.read(profileUpdateProvider.notifier);
                await notifier.updateUserProfile(
                  UserProfileUpdateInput(
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                    bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
                  ),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                }
              },
            ),
            const SizedBox(height: AppTheme.spacing32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Components
// ---------------------------------------------------------------------------

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: AppTheme.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.display.copyWith(fontSize: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.micro.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.isVerified});
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.primary : Colors.amber.shade700;
    final text = isVerified ? 'APPROVED' : 'PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.borderRadiusPill,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: AppTextStyles.micro.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BankAccountTile extends ConsumerWidget {
  const _BankAccountTile({required this.account});
  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: AppTheme.borderRadiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(account.bankName, style: AppTextStyles.label),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(account.type.toUpperCase(), style: AppTextStyles.micro),
                    ),
                    if (account.isPrimary) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('PRIMARY', style: AppTextStyles.micro.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(account.accountHolder, style: AppTextStyles.body),
                Text('•••• ${account.accountNumber.length > 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}', style: AppTextStyles.body.copyWith(color: AppColors.textBody)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete bank account'),
                  content: const Text('Are you sure you want to delete this bank account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;
              await ref.read(bankAccountMutationProvider.notifier).remove(account.id);
            },
          ),
        ],
      ),
    );
  }
}
