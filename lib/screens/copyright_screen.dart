import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class CopyrightScreen extends StatelessWidget {
  const CopyrightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Copyright',
      kicker: 'Copyright',
      blocks: AppCopy.copyright,
    );
  }
}
