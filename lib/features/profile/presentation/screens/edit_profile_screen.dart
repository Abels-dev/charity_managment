import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/features/profile/presentation/providers/current_profile_provider.dart';
import 'package:charity_managment/features/profile/presentation/providers/profile_update_provider.dart';
import 'package:charity_managment/features/profile/presentation/utils/profile_validators.dart';

import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/async_value_view.dart';

import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/dashed_card.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _documentPathController = TextEditingController();
  final _logoPathController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _documentPathController.dispose();
    _logoPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final updateState = ref.watch(profileUpdateProvider);

    return AppScaffold(
      title: 'Edit Profile',
      body: AsyncValueView(
        value: profileAsync,
        data: (profile) {
          if (!_initialized) {
            _seedControllers(profile);
            _initialized = true;
          }

          final user = profile.user;
          final isCharity = user.role == ProfileRole.charity;
          final isCreatingCharityProfile = isCharity && profile.charityProfile == null;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppTheme.spacing16),
                  CircleAvatar(
                    radius: 48,
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
                  Text(
                    user.name,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppTheme.borderRadiusPill,
                    ),
                    child: Text(
                      user.role.label,
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  AppCard(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profile Details', style: AppTextStyles.title),
                        const SizedBox(height: AppTheme.spacing24),
                        FormInput(
                          label: isCharity ? 'Organization name' : 'Full name',
                          controller: _nameController,
                          hint: isCharity ? 'Enter organization name' : 'Enter full name',
                          validator: (value) => ProfileValidators.requiredText(
                            value,
                            isCharity ? 'Organization name' : 'Full name',
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        FormInput(
                          label: 'Phone',
                          controller: _phoneController,
                          hint: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          validator: ProfileValidators.phone,
                        ),
                        if (!isCharity) ...[
                          const SizedBox(height: AppTheme.spacing16),
                          FormInput(
                            label: 'Bio',
                            controller: _bioController,
                            hint: 'Tell us a bit about yourself...',
                            maxLines: 3,
                          ),
                        ],
                        if (isCharity) ...[
                          const SizedBox(height: AppTheme.spacing16),
                          FormInput(
                            label: 'Description',
                            controller: _descriptionController,
                            hint: 'Describe your organization...',
                            maxLines: 3,
                          ),
                          if (isCreatingCharityProfile) ...[
                            const SizedBox(height: AppTheme.spacing24),
                            Text('Required Document', style: AppTextStyles.label),
                            const SizedBox(height: AppTheme.spacing8),
                            _FilePickerButton(
                              value: _documentPathController.text,
                              onPressed: _pickDocument,
                            ),
                            const SizedBox(height: AppTheme.spacing24),
                            Text('Organization Logo', style: AppTextStyles.label),
                            const SizedBox(height: AppTheme.spacing8),
                            _FilePickerButton(
                              value: _logoPathController.text,
                              onPressed: _pickLogo,
                            ),
                          ],
                          const SizedBox(height: AppTheme.spacing16),
                          FormInput(
                            label: 'Website',
                            controller: _websiteController,
                            hint: 'https://example.org',
                            keyboardType: TextInputType.url,
                            validator: ProfileValidators.website,
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          FormInput(
                            label: 'Address',
                            controller: _addressController,
                            hint: '123 Charity Ave...',
                            maxLines: 2,
                          ),
                        ],
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
                      ),
                    ),
                  AppButton(
                    text: 'Save changes',
                    isLoading: updateState.isLoading,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await _submit(
                        profile.user.role,
                        createProfile: isCreatingCharityProfile,
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _seedControllers(ProfileData profile) {
    _nameController.text = profile.user.name;
    _phoneController.text = profile.user.phone ?? '';
    _bioController.text = profile.user.bio ?? '';

    final charity = profile.charityProfile;
    _descriptionController.text = charity?.description ?? '';
    _websiteController.text = charity?.website ?? '';
    _addressController.text = charity?.address ?? '';
    _documentPathController.text = charity?.documentUrl ?? '';
    _logoPathController.text = '';
  }

  Future<void> _submit(ProfileRole role, {required bool createProfile}) async {
    final notifier = ref.read(profileUpdateProvider.notifier);
    if (role == ProfileRole.charity) {
      final updated = createProfile
          ? await notifier.createCharityProfile(
              organizationName: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              documentPath: _documentPathController.text.trim(),
              logoPath: _logoPathController.text.trim().isEmpty
                  ? null
                  : _logoPathController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              website: _websiteController.text.trim().isEmpty
                  ? null
                  : _websiteController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
            )
          : await notifier.updateCharityProfile(
              CharityProfileUpdateInput(
                organizationName: _nameController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
                website: _websiteController.text.trim().isEmpty
                    ? null
                    : _websiteController.text.trim(),
                address: _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
              ),
            );
      if (updated != null && mounted) {
        context.pop();
      }
    } else {
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
        context.pop();
      }
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
    final result = await FilePicker.platform.pickFiles(withData: false);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _logoPathController.text = path);
    }
  }
}

class _FilePickerButton extends StatelessWidget {
  const _FilePickerButton({
    required this.value,
    required this.onPressed,
  });

  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DashedCard(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primary),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                value.isEmpty ? 'Tap to upload' : value.split('/').last,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              if (value.isEmpty) ...[
                const SizedBox(height: AppTheme.spacing4),
                Text('PNG, JPG or PDF (max. 10MB)', style: AppTextStyles.micro),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
