import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_error_message.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_form_card.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_primary_button.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_role_card.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_screen_shell.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/routing/app_routes.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScreenShell(
      title: 'Choose your role',
      subtitle: 'You can update this later from profile settings.',
      child: AuthFormCard(
        child: Column(
          children: [
            if (authState.errorMessage != null) ...[
              AuthErrorMessage(message: authState.errorMessage!),
              const SizedBox(height: 12),
            ],
            AuthRoleCard(
              role: UserRole.donor,
              selected: authState.selectedRole == UserRole.donor,
              onTap: () => controller.selectRole(UserRole.donor),
            ),
            const SizedBox(height: 12),
            AuthRoleCard(
              role: UserRole.charityOrganization,
              selected: authState.selectedRole == UserRole.charityOrganization,
              onTap: () => controller.selectRole(UserRole.charityOrganization),
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Continue',
              onPressed: authState.selectedRole == null
                  ? null
                  : () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
