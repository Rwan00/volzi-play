import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Privacy Policy',
      kicker: 'Privacy',
      blocks: AppCopy.privacy,
    );
  }
}
