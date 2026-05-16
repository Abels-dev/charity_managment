import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/presentation/utils/auth_validators.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_error_message.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_form_card.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_primary_button.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_screen_shell.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:charity_managment/routing/app_routes.dart';

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

    return AuthScreenShell(
      title: 'Forgot password',
      subtitle: 'Enter your account email and we will send reset instructions.',
      bottom: Center(
        child: TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Back to login'),
        ),
      ),
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (state.errorMessage != null) ...[
                AuthErrorMessage(message: state.errorMessage!),
                const SizedBox(height: 12),
              ],
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.email_outlined,
                validator: AuthValidators.email,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(
                label: 'Send reset email',
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
