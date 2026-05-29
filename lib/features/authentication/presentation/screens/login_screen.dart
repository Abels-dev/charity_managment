import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/domain/models/auth_status.dart';
import 'package:charity_managment/features/authentication/presentation/utils/auth_validators.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_error_message.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_form_card.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_primary_button.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_screen_shell.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

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

    return AuthScreenShell(
      title: 'Log in',
      subtitle: 'Continue as ${state.selectedRole?.label ?? 'your selected role'}.',
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?"),
          TextButton(
            onPressed: () => context.go(AppRoutes.register),
            child: const Text('Register'),
          ),
        ],
      ),
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                AuthErrorMessage(message: state.errorMessage!),
                const SizedBox(height: 12),
              ],
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.email_outlined,
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline,
                validator: AuthValidators.password,
                onFieldSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              AuthPrimaryButton(
                label: 'Log in',
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.roleSelection),
                child: const Text('Change role'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
