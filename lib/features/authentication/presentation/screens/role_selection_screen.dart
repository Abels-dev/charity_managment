import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/models/user_role.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface, // #F8FAFC
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.onboarding);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacing16),
              // Centered Title
              Text(
                'Join as...',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing8),
              // Subtitle
              Text(
                'Select how you want to use the platform',
                style: AppTextStyles.body.copyWith(color: AppColors.textBody),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing48),
              
              if (authState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                  child: Text(
                    authState.errorMessage!,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Donor Card
              _RoleCard(
                title: 'I want to Donate',
                subtitle: 'Browse campaigns and support causes you care about',
                icon: Icons.volunteer_activism, // person/heart like
                isSelected: authState.selectedRole == UserRole.donor,
                onTap: () {
                  controller.selectRole(UserRole.donor);
                  context.go(AppRoutes.register);
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Charity Card
              _RoleCard(
                title: 'I represent a Charity',
                subtitle: 'Create campaigns and manage donations for your organization',
                icon: Icons.domain, // building/org
                isSelected: authState.selectedRole == UserRole.charityOrganization,
                onTap: () {
                  controller.selectRole(UserRole.charityOrganization);
                  context.go(AppRoutes.charityInfo);
                },
              ),

              const SizedBox(height: AppTheme.spacing16),

              const Spacer(),
              // Bottom login link
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textBody,
                ),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.body.copyWith(color: AppColors.textBody),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Login',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: AppTheme.borderRadiusLg, // 16px
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textBody, fontSize: 13, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
