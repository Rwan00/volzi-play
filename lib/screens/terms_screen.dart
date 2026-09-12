import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Terms of Use',
      kicker: 'Terms',
      blocks: AppCopy.terms,
    );
  }
}
