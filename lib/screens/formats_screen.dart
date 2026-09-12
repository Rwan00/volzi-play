import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../widgets/info_page.dart';

class FormatsScreen extends StatelessWidget {
  const FormatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Supported formats',
      kicker: 'Formats',
      blocks: AppCopy.formats,
    );
  }
}
