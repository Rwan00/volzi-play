import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/copyright_screen.dart';
import '../screens/disclaimer_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/formats_screen.dart';
import '../screens/how_to_use_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/terms_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'atmosphere.dart';
import 'brand_mark.dart';

class VolziDrawer extends StatelessWidget {
  const VolziDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.86,
      child: NightBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              const BrandMark(size: 86),
              const SizedBox(height: 16),
              Text(AppCopy.brand.toUpperCase(), style: AppTheme.cinzel(size: 18, letterSpacing: 5)),
              const SizedBox(height: 6),
              Text(
                AppCopy.tagline,
                style: AppTheme.elMessiri(size: 16, color: AppColors.goldSoft, weight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Version ${AppCopy.version}  ·  iOS',
                style: AppTheme.cairo(size: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              const GoldHairline(indent: 28),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  children: const [
                    _Item(icon: Icons.play_circle_outline_rounded, label: 'Player', home: true),
                    _Item(icon: Icons.auto_awesome_outlined, label: 'About Volzi Play', page: AboutScreen()),
                    _Item(icon: Icons.menu_book_outlined, label: 'How to use', page: HowToUseScreen()),
                    _Item(icon: Icons.layers_outlined, label: 'Supported formats', page: FormatsScreen()),
                    _Item(icon: Icons.help_outline_rounded, label: 'FAQ', page: FaqScreen()),
                    _Item(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', page: PrivacyScreen()),
                    _Item(icon: Icons.gavel_outlined, label: 'Terms of Use', page: TermsScreen()),
                    _Item(icon: Icons.copyright_rounded, label: 'Copyright', page: CopyrightScreen()),
                    _Item(icon: Icons.balance_outlined, label: 'Disclaimer', page: DisclaimerScreen()),
                    _Item(icon: Icons.mail_outline_rounded, label: 'Contact', page: ContactScreen()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  'Designed for visual quiet on iOS',
                  style: AppTheme.cairo(size: 12, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    this.page,
    this.home = false,
  });

  final IconData icon;
  final String label;
  final Widget? page;
  final bool home;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.graphite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        title: Text(label, style: AppTheme.cairo(size: 15.5, weight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.goldSoft),
        onTap: () {
          Navigator.pop(context);
          if (home || page == null) return;
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, animation, _) => page!,
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.04, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
          ));
        },
      ),
    );
  }
}
