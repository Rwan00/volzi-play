import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'How to use',
      kicker: 'Guide',
      blocks: AppCopy.howTo,
    );
  }
}
