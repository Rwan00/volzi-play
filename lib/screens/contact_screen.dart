import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_copy.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/gold_button.dart';
import '../widgets/info_page.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _mail(BuildContext context, String email, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.graphite,
          content: Text('Could not open Mail. Copy the address instead.', style: AppTheme.cairo(size: 14)),
        ),
      );
    }
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.graphite,
        content: Text('Copied $value', style: AppTheme.cairo(size: 14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      title: 'Contact',
      kicker: 'Contact',
      blocks: AppCopy.contact,
      footer: Column(
        children: [
          GoldButton(
            label: 'Email support',
            icon: Icons.mail_outline_rounded,
            onPressed: () => _mail(context, AppCopy.supportEmail, 'Volzi Play support'),
          ),
          const SizedBox(height: 12),
          GoldButton(
            label: 'Email legal',
            icon: Icons.balance_outlined,
            onPressed: () => _mail(context, AppCopy.legalEmail, 'Legal — Volzi Play'),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () => _copy(context, AppCopy.supportEmail),
            child: Text(AppCopy.supportEmail, style: AppTheme.cairo(color: AppColors.goldSoft)),
          ),
          TextButton(
            onPressed: () => _copy(context, AppCopy.legalEmail),
            child: Text(AppCopy.legalEmail, style: AppTheme.cairo(color: AppColors.goldSoft)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
