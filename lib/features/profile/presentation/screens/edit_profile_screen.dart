import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/profile/domain/models/charity_profile_update_input.dart';
import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';
import 'package:charity_managment/features/profile/domain/models/user_profile_update_input.dart';
import 'package:charity_managment/features/profile/presentation/providers/current_profile_provider.dart';
import 'package:charity_managment/features/profile/presentation/providers/profile_update_provider.dart';
import 'package:charity_managment/features/profile/presentation/utils/profile_validators.dart';
import 'package:charity_managment/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:charity_managment/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/async_value_view.dart';

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

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
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

          final isCharity = profile.user.role == ProfileRole.charity;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileSectionCard(
                    title: 'Profile details',
                    child: Column(
                      children: [
                        ProfileTextField(
                          label: isCharity ? 'Organization name' : 'Full name',
                          controller: _nameController,
                          validator: (value) => ProfileValidators.requiredText(
                            value,
                            isCharity ? 'Organization name' : 'Full name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ProfileTextField(
                          label: 'Phone',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: ProfileValidators.phone,
                        ),
                        if (!isCharity) ...[
                          const SizedBox(height: 12),
                          ProfileTextField(
                            label: 'Bio',
                            controller: _bioController,
                            maxLines: 3,
                          ),
                        ],
                        if (isCharity) ...[
                          const SizedBox(height: 12),
                          ProfileTextField(
                            label: 'Description',
                            controller: _descriptionController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          ProfileTextField(
                            label: 'Website',
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                            validator: ProfileValidators.website,
                          ),
                          const SizedBox(height: 12),
                          ProfileTextField(
                            label: 'Address',
                            controller: _addressController,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (updateState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        updateState.error.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: updateState.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              await _submit(profile.user.role);
                            },
                      child: updateState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ),
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
  }

  Future<void> _submit(ProfileRole role) async {
    final notifier = ref.read(profileUpdateProvider.notifier);
    if (role == ProfileRole.charity) {
      final updated = await notifier.updateCharityProfile(
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
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        ),
      );
      if (updated != null && mounted) {
        context.pop();
      }
    }
  }
}
