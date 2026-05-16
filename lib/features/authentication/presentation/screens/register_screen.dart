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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScreenShell(
      title: 'Create account',
      subtitle: 'Register as ${state.selectedRole?.label ?? 'your selected role'}.',
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Log in'),
          ),
        ],
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
                controller: _nameController,
                label: 'Full name',
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline,
                validator: AuthValidators.fullName,
              ),
              const SizedBox(height: 12),
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
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline,
                validator: AuthValidators.password,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline,
                validator: (value) =>
                    AuthValidators.confirmPassword(value, _passwordController.text),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(
                label: 'Register',
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
