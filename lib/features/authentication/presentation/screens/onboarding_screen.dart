import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_error_message.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_form_card.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_primary_button.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_screen_shell.dart';
import 'package:charity_managment/routing/app_routes.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScreenShell(
      title: 'Welcome',
      subtitle: 'Manage donations, campaigns, and impact in one place.',
      child: AuthFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authState.errorMessage != null) ...[
              AuthErrorMessage(message: authState.errorMessage!),
              const SizedBox(height: 12),
            ],
            const _BenefitItem(
              icon: Icons.campaign,
              text: 'Discover and support transparent campaigns',
            ),
            const SizedBox(height: 12),
            const _BenefitItem(
              icon: Icons.payments_outlined,
              text: 'Track your donations and impact',
            ),
            const SizedBox(height: 12),
            const _BenefitItem(
              icon: Icons.dashboard_customize_outlined,
              text: 'Organizations can manage campaigns and performance',
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Get Started',
              isLoading: authState.isSubmitting,
              onPressed: () async {
                await controller.completeOnboarding();
                if (context.mounted) {
                  context.go(AppRoutes.roleSelection);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
