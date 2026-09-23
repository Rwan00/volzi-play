import 'package:flutter/material.dart';

import '../models/library_video.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/play_route.dart';
import '../utils/time_format.dart';
import '../widgets/add_video_sheet.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/gold_button.dart';
import '../widgets/shell_header.dart';
import '../widgets/video_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NightBackdrop(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (context, _) {
            final store = LibraryStore.instance;
            final resume = store.continueWatching;
            final recent = store.history.take(5).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              children: [
                ShellHeader(
                  title: 'Home',
                  action: IconButton(
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
                    },
                    icon: const Icon(Icons.tune_rounded, color: AppColors.goldSoft),
                  ),
                ),
                _StatsRow(store: store),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Build your private cinema', style: AppTheme.elMessiri(size: 22, color: AppColors.gold)),
                        const SizedBox(height: 8),
                        Text(
                          'Save streams and files, resume where you left off, keep favorites, and play curated lists.',
                          style: AppTheme.cairo(size: 14, color: AppColors.muted, height: 1.7),
                        ),
                        const SizedBox(height: 16),
                        GoldButton(
                          label: 'Add a video',
                          icon: Icons.add_rounded,
                          onPressed: () => showAddVideoSheet(context, playAfterSave: true),
                        ),
                      ],
                    ),
                  ),
                ),
                if (resume.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _SectionTitle(
                    title: 'Continue watching',
                    onSeeAll: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HistoryScreen())),
                  ),
                  const SizedBox(height: 8),
                  _ContinueCard(video: resume.first),
                ],
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Recently played',
                  onSeeAll: recent.isEmpty
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HistoryScreen())),
                ),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'No playback yet',
                    message: 'Add a video to your library and play it. History, resume points, and favorites stay on this device.',
                  )
                else
                  ...recent.map((video) => VideoTile(video: video)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.store});

  final LibraryStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'Library', value: '${store.videos.length}'),
        const SizedBox(width: 8),
        _StatChip(label: 'Saved', value: '${store.favorites.length}'),
        const SizedBox(width: 8),
        _StatChip(label: 'Playlists', value: '${store.playlists.length}'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.graphite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(value, style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
              Text(label, style: AppTheme.cairo(size: 12, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.elMessiri(size: 20)),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text('See all', style: AppTheme.cairo(size: 13, color: AppColors.gold)),
          ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.video});

  final LibraryVideo video;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.graphite,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => openPlayer(context, videoId: video.id),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: AppTheme.elMessiri(size: 20, color: AppColors.goldSoft)),
                const SizedBox(height: 6),
                Text(
                  'Resume at ${TimeFormat.clock(Duration(milliseconds: video.lastPositionMs))}  ·  ${video.format}',
                  style: AppTheme.cairo(size: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: video.progress,
                    minHeight: 4,
                    color: AppColors.gold,
                    backgroundColor: AppColors.line,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
