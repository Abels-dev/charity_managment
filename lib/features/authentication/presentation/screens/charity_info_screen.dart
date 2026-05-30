import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/routing/app_routes.dart';

const _charityWebsiteUrl = 'https://61f7-196-188-33-79.ngrok-free.app';

class CharityInfoScreen extends StatelessWidget {
  const CharityInfoScreen({super.key});

  Future<void> _openWebsite(BuildContext context) async {
    final uri = Uri.parse(_charityWebsiteUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      Text(
                        'Register on the Web',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      Text(
                        'Charity registration is only available on our website. Please register there and come back to login here.',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      AppButton(
                        text: 'Go to Website',
                        icon: const Icon(Icons.open_in_new, color: AppColors.surface, size: 18),
                        onPressed: () => _openWebsite(context),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      AppButton(
                        text: 'Back to login',
                        type: AppButtonType.secondary,
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                      ),
                    ],
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
