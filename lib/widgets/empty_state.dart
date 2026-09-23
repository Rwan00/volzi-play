import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.charcoal.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
          child: Column(
            children: [
              Icon(icon, color: AppColors.gold, size: 32),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: AppTheme.elMessiri(size: 20)),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.cairo(size: 14, color: AppColors.muted, height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
