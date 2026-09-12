import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'FAQ',
      kicker: 'FAQ',
      blocks: AppCopy.faq,
    );
  }
}
