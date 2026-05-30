import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/routing/app_routes.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface, // #F8FAFC
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
                vertical: AppTheme.spacing32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Large emerald hero element / icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.volunteer_activism,
                        size: 72,
                        color: AppColors.primary, // emerald
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing48),
                  // App name
                  Text(
                    'Charity\nManagement',
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.textPrimary, // slate-900
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  // Tagline
                  Text(
                    'Manage donations, campaigns, and impact in one place.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textBody, // slate-500
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  
                  if (authState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                      child: Text(
                        authState.errorMessage!,
                        style: AppTextStyles.body.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Get Started button
                  AppButton(
                    text: 'Get Started',
                    isLoading: authState.isSubmitting,
                    onPressed: () async {
                      await controller.completeOnboarding();
                      if (context.mounted) {
                        context.go(AppRoutes.roleSelection);
                      }
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  // Login link
                  TextButton(
                    onPressed: () async {
                      await controller.completeOnboarding();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
