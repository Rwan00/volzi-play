import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'atmosphere.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    super.key,
    required this.title,
    required this.kicker,
    required this.blocks,
    this.footer,
  });

  final String title;
  final String kicker;
  final List<CopyBlock> blocks;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: NightBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          children: [
            Text(
              kicker.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTheme.cinzel(size: 11, letterSpacing: 5, color: AppColors.goldSoft),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.elMessiri(size: 32, color: AppColors.gold),
            ),
            const SizedBox(height: 14),
            const GoldHairline(indent: 48),
            const SizedBox(height: 28),
            ...blocks.map(
              (block) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.title,
                          style: AppTheme.elMessiri(size: 20, color: AppColors.goldSoft),
                        ),
                        const SizedBox(height: 10),
                        Text(block.body, style: AppTheme.cairo(size: 15.5, height: 1.9)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ?footer,
            const SizedBox(height: 12),
            Text(
              '© ${AppCopy.copyrightYear} ${AppCopy.brand}',
              textAlign: TextAlign.center,
              style: AppTheme.cairo(size: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
