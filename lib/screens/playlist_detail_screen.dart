import 'package:flutter/material.dart';

import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/play_route.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/gold_button.dart';
import '../widgets/video_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LibraryStore.instance,
      builder: (context, _) {
        final store = LibraryStore.instance;
        final playlist = store.playlistById(playlistId);
        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Playlist')),
            body: const EmptyState(
              icon: Icons.queue_play_next_rounded,
              title: 'Playlist missing',
              message: 'This list was deleted.',
            ),
          );
        }
        final videos = store.videosIn(playlist);
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.name),
            actions: [
              IconButton(
                tooltip: 'Rename',
                onPressed: () async {
                  final controller = TextEditingController(text: playlist.name);
                  final name = await showDialog<String>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.charcoal,
                        title: Text('Rename playlist', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
                        content: TextField(controller: controller, style: AppTheme.cairo(size: 15)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel', style: AppTheme.cairo(color: AppColors.muted))),
                          TextButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: Text('Save', style: AppTheme.cairo(color: AppColors.gold))),
                        ],
                      );
                    },
                  );
                  controller.dispose();
                  if (name != null) await store.renamePlaylist(playlist.id, name);
                },
                icon: const Icon(Icons.drive_file_rename_outline_rounded),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  await store.deletePlaylist(playlist.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          body: NightBackdrop(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                if (videos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GoldButton(
                      label: 'Play from start',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => openPlayer(context, videoId: videos.first.id, playlistId: playlist.id),
                    ),
                  ),
                if (videos.isEmpty)
                  const EmptyState(
                    icon: Icons.playlist_add_rounded,
                    title: 'This list is empty',
                    message: 'Open any video in your library and use Add to playlist to fill this queue.',
                  )
                else
                  ...videos.map((video) {
                    return VideoTile(
                      video: video,
                      playlistId: playlist.id,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => store.moveInPlaylist(playlist.id, video.id, -1),
                            icon: const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.goldSoft),
                          ),
                          IconButton(
                            onPressed: () => store.moveInPlaylist(playlist.id, video.id, 1),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.goldSoft),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
