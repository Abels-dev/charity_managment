import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/presentation/utils/auth_validators.dart';
import 'package:charity_managment/routing/app_routes.dart';

import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset email sent (mock).')),
      );
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Forgot password',
                  style: AppTextStyles.display,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Enter your account email and we will send reset instructions.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing32),
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppTheme.borderRadiusSm,
                            ),
                            child: Text(
                              state.errorMessage!,
                              style: AppTextStyles.body.copyWith(color: AppColors.error),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                        ],
                        FormInput(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: AuthValidators.email,
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        AppButton(
                          text: 'Send reset email',
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Back to login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
