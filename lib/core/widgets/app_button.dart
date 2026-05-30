import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum AppButtonType { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton();
      case AppButtonType.secondary:
        return _buildSecondaryButton();
      case AppButtonType.outline:
        return _buildOutlineButton();
    }
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: onPressed == null ? AppColors.border : AppColors.primary,
        borderRadius: AppTheme.borderRadiusMd,
        boxShadow: onPressed == null ? [] : AppTheme.primaryButtonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppTheme.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing16,
              horizontal: AppTheme.spacing24,
            ),
            child: _buildContent(AppColors.surface),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: AppTheme.borderRadiusMd,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppTheme.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing16,
              horizontal: AppTheme.spacing24,
            ),
            child: _buildContent(AppColors.primaryDark),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppTheme.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing16,
              horizontal: AppTheme.spacing24,
            ),
            child: _buildContent(AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppTheme.spacing8),
        ],
        Text(
          text,
          style: AppTextStyles.label.copyWith(color: textColor),
        ),
      ],
    );
  }
}
