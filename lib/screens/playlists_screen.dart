import 'package:flutter/material.dart';

import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/shell_header.dart';
import '../widgets/video_tile.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NightBackdrop(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (context, _) {
            final playlists = LibraryStore.instance.playlists;
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              children: [
                ShellHeader(
                  title: 'Playlists',
                  action: IconButton(
                    tooltip: 'New playlist',
                    onPressed: () => promptCreatePlaylist(context),
                    icon: const Icon(Icons.playlist_add_rounded, color: AppColors.gold),
                  ),
                ),
                if (playlists.isEmpty)
                  const EmptyState(
                    icon: Icons.queue_play_next_rounded,
                    title: 'No playlists yet',
                    message: 'Create a list for evenings, sports, or study streams, then play them in order with autoplay.',
                  )
                else
                  ...playlists.map((playlist) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: AppColors.line),
                        ),
                        tileColor: AppColors.graphite,
                        leading: const Icon(Icons.queue_play_next_rounded, color: AppColors.gold),
                        title: Text(playlist.name, style: AppTheme.cairo(weight: FontWeight.w700)),
                        subtitle: Text(
                          '${playlist.videoIds.length} videos',
                          style: AppTheme.cairo(size: 12, color: AppColors.muted),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.goldSoft),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}
