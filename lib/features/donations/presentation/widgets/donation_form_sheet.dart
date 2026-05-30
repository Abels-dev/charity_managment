import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/donations/domain/donation_create_input.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_submission_provider.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/models/donation.dart';

import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class DonationFormSheet extends ConsumerStatefulWidget {
  const DonationFormSheet({
    super.key,
    required this.campaign,
    this.onSuccess,
  });

  final Campaign campaign;
  final ValueChanged<String>? onSuccess;

  @override
  ConsumerState<DonationFormSheet> createState() => _DonationFormSheetState();
}

class _DonationFormSheetState extends ConsumerState<DonationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _messageController;
  late final TextEditingController _guestNameController;
  late final TextEditingController _guestEmailController;
  late final ProviderSubscription<AsyncValue<Donation?>> _submissionSub;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _messageController = TextEditingController();
    _guestNameController = TextEditingController();
    _guestEmailController = TextEditingController();

    _submissionSub = ref.listenManual<AsyncValue<Donation?>>(
      donationSubmissionProvider,
      (previous, next) {
        if (next.hasError) {
          if (!mounted) return;
          final message = next.error.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }

        if (next.hasValue && next.value != null) {
          if (!mounted) return;
          widget.onSuccess?.call(next.value!.id);
        }
      },
    );
  }

  @override
  void dispose() {
    _submissionSub.close();
    _amountController.dispose();
    _messageController.dispose();
    _guestNameController.dispose();
    _guestEmailController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', ''));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = _parseAmount();
    if (amount == null) return;

    final user = ref.read(authControllerProvider).user;
    final donorName = user?.fullName ?? _guestNameController.text.trim();
    final donorEmail = user?.email ?? _guestEmailController.text.trim();

    if (user == null && (donorName.isEmpty || donorEmail.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and email to donate.')),
      );
      return;
    }

    await ref.read(donationSubmissionProvider.notifier).submit(
          DonationCreateInput(
            donorId: user?.id,
            donorName: user == null ? donorName : null,
            donorEmail: user == null ? donorEmail : null,
            campaignId: widget.campaign.id,
            amount: amount,
            isAnonymous: _isAnonymous,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(donationSubmissionProvider);
    final isLoading = submission.isLoading;
    final mediaQuery = MediaQuery.of(context);
    final user = ref.watch(authControllerProvider).user;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppTheme.spacing24,
        right: AppTheme.spacing24,
        top: AppTheme.spacing32,
        bottom: mediaQuery.viewInsets.bottom + AppTheme.spacing24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donate to ${widget.campaign.title}',
              style: AppTextStyles.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Enter the amount you wish to contribute to this campaign.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppTheme.spacing24),
            FormInput(
              controller: _amountController,
              label: 'Donation amount',
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: AppTheme.spacing16, right: AppTheme.spacing8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ETB', style: AppTextStyles.label.copyWith(color: AppColors.textBody)),
                  ],
                ),
              ),
              validator: (_) {
                final amount = _parseAmount();
                if (amount == null) {
                  return 'Please enter a valid amount.';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              controller: _messageController,
              label: 'Optional message',
              hint: 'Leave a word of support...',
              maxLines: 3,
            ),
            if (user == null) ...[
              const SizedBox(height: AppTheme.spacing16),
              FormInput(
                controller: _guestNameController,
                label: 'Full name',
                hint: 'Enter your name',
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
              FormInput(
                controller: _guestEmailController,
                label: 'Email address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'Please enter your email.';
                  }
                  if (!text.contains('@') || !text.contains('.')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
            ] else ...[
              const SizedBox(height: AppTheme.spacing16),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: AppTheme.borderRadiusMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.primary),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: AppTextStyles.label),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(user.email, style: AppTextStyles.micro),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacing24),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: AppTheme.borderRadiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Donate anonymously', style: AppTextStyles.label),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          'Hide your identity from the campaign creator.',
                          style: AppTextStyles.micro,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isAnonymous,
                    activeThumbColor: AppColors.primary,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isAnonymous = value;
                            });
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing32),
            AppButton(
              text: 'Confirm Donation',
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppTheme.spacing12),
          ],
        ),
      ),
    );
  }
}
