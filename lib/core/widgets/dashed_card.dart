import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class DashedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsets? padding;
  final bool isCircle;

  const DashedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.primary,
    this.padding,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(color: color, isCircle: isCircle),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : AppTheme.borderRadiusLg,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final bool isCircle;

  _DashedRectPainter({required this.color, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    if (isCircle) {
      path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(AppTheme.radiusLg),
      );
      path.addRRect(rrect);
    }
    
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double distance = 0.0;
    
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
