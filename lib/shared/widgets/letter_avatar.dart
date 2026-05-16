import 'package:flutter/material.dart';

class LetterAvatar extends StatelessWidget {
  const LetterAvatar({
    super.key,
    required this.name,
    this.size = 56,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(name);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = foregroundColor ?? theme.colorScheme.onPrimaryContainer;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: Text(
        initials,
        style: theme.textTheme.titleLarge?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}
