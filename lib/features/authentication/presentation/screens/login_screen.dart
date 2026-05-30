import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_status.dart';
import 'package:charity_managment/features/authentication/presentation/utils/auth_validators.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status != AuthStatus.authenticated && next.status == AuthStatus.authenticated) {
        final target = next.user?.role == UserRole.charityOrganization
            ? AppRoutes.charityDashboard
            : AppRoutes.campaigns;
        if (context.mounted) {
          context.go(target);
        }
      }
    });

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
                  'Log in',
                  style: AppTextStyles.display,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Continue as ${state.selectedRole?.label ?? 'your selected role'}.',
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
                        const SizedBox(height: AppTheme.spacing16),
                        FormInput(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: AuthValidators.password,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.forgotPassword),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        AppButton(
                          text: 'Log in',
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        AppButton(
                          text: 'Change role',
                          type: AppButtonType.outline,
                          onPressed: () => context.go(AppRoutes.roleSelection),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: AppTextStyles.body),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
