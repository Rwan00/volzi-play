import 'package:flutter/material.dart';

import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/video_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch history'),
        actions: [
          TextButton(
            onPressed: () => LibraryStore.instance.clearHistory(),
            child: Text('Clear', style: AppTheme.cairo(size: 13, color: AppColors.gold)),
          ),
        ],
      ),
      body: NightBackdrop(
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (context, _) {
            final history = LibraryStore.instance.history;
            if (history.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'History is empty',
                message: 'Videos you play appear here with their last position so you can jump back in.',
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: history.map((video) => VideoTile(video: video)).toList(),
            );
          },
        ),
      ),
    );
  }
}
