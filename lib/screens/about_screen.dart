import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'About Volzi Play',
      kicker: 'The House',
      blocks: AppCopy.about,
    );
  }
}
