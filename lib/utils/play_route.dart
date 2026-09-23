import 'package:flutter/material.dart';

import '../screens/player_screen.dart';

Future<void> openPlayer(
  BuildContext context, {
  required String videoId,
  String? playlistId,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, animation, _) => PlayerScreen(videoId: videoId, playlistId: playlistId),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    ),
  );
}
