import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({
    super.key,
    required this.category,
  });

  static const Map<String, Color> _categoryColors = {
    'education': Color(0xFF3B82F6),
    'health': Color(0xFFEF4444),
    'water': Color(0xFF06B6D4),
    'food': Color(0xFFF59E0B),
    'environment': Color(0xFF10B981),
    'emergency': Color(0xFFF97316),
    'default': Color(0xFF64748B),
  };

  @override
  Widget build(BuildContext context) {
    final String normalizedCategory = category.toLowerCase();
    final Color badgeColor = _categoryColors[normalizedCategory] ?? _categoryColors['default']!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: AppTheme.borderRadiusSm,
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTextStyles.micro.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
