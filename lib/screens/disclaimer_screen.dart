import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Disclaimer',
      kicker: 'Disclaimer',
      blocks: AppCopy.disclaimer,
    );
  }
}
