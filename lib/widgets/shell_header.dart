import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ShellHeader extends StatelessWidget {
  const ShellHeader({
    super.key,
    required this.title,
    this.action,
  });

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.gold),
          ),
          Expanded(
            child: Column(
              children: [
                Text(AppCopy.brand.toUpperCase(), style: AppTheme.cinzel(size: 11, letterSpacing: 3)),
                Text(title, style: AppTheme.elMessiri(size: 22)),
              ],
            ),
          ),
          action ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
