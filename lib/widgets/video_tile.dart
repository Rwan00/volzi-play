import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/library_video.dart';
import '../models/playlist.dart';
import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/play_route.dart';
import '../utils/time_format.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({
    super.key,
    required this.video,
    this.playlistId,
    this.trailing,
  });

  final LibraryVideo video;
  final String? playlistId;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.graphite,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openPlayer(context, videoId: video.id, playlistId: playlistId),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Icon(
                      video.favorite ? Icons.favorite_rounded : Icons.play_arrow_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.cairo(size: 15, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle(video),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.cairo(size: 12, color: AppColors.muted),
                        ),
                        if (video.canResume) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: video.progress,
                              minHeight: 3,
                              color: AppColors.gold,
                              backgroundColor: AppColors.line,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing ??
                      IconButton(
                        onPressed: () => showVideoActions(context, video, playlistId: playlistId),
                        icon: const Icon(Icons.more_horiz_rounded, color: AppColors.goldSoft),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _subtitle(LibraryVideo video) {
    final bits = <String>[video.format];
    if (video.canResume) {
      bits.add('Resume ${TimeFormat.clock(Duration(milliseconds: video.lastPositionMs))}');
    } else if (video.durationMs > 0) {
      bits.add(TimeFormat.clock(Duration(milliseconds: video.durationMs)));
    }
    if (video.playCount > 0) bits.add('${video.playCount}x');
    return bits.join('  ·  ');
  }
}

Future<void> showVideoActions(
  BuildContext context,
  LibraryVideo video, {
  String? playlistId,
}) async {
  final store = LibraryStore.instance;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.charcoal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(video.title, style: AppTheme.elMessiri(size: 18, color: AppColors.gold)),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(video.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.gold),
                title: Text(video.favorite ? 'Remove from saved' : 'Save to favorites', style: AppTheme.cairo(weight: FontWeight.w600)),
                onTap: () async {
                  await store.toggleFavorite(video.id);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline_rounded, color: AppColors.gold),
                title: Text('Rename', style: AppTheme.cairo(weight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await promptRenameVideo(context, video);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded, color: AppColors.gold),
                title: Text('Add to playlist', style: AppTheme.cairo(weight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await promptAddToPlaylist(context, video.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: AppColors.gold),
                title: Text('Copy link', style: AppTheme.cairo(weight: FontWeight.w600)),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: video.url));
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.graphite,
                        content: Text('Link copied', style: AppTheme.cairo(size: 14)),
                      ),
                    );
                  }
                },
              ),
              if (playlistId != null)
                ListTile(
                  leading: const Icon(Icons.playlist_remove_rounded, color: AppColors.gold),
                  title: Text('Remove from this playlist', style: AppTheme.cairo(weight: FontWeight.w600)),
                  onTap: () async {
                    await store.removeFromPlaylist(playlistId, video.id);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: Text('Remove from library', style: AppTheme.cairo(weight: FontWeight.w600, color: AppColors.danger)),
                onTap: () async {
                  await store.removeVideo(video.id);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> promptRenameVideo(BuildContext context, LibraryVideo video) async {
  final controller = TextEditingController(text: video.title);
  final next = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('Rename video', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTheme.cairo(size: 15),
          decoration: const InputDecoration(hintText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTheme.cairo(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text('Save', style: AppTheme.cairo(color: AppColors.gold, weight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (next == null) return;
  await LibraryStore.instance.rename(video.id, next);
}

Future<void> promptAddToPlaylist(BuildContext context, String videoId) async {
  final store = LibraryStore.instance;
  if (store.playlists.isEmpty) {
    final created = await promptCreatePlaylist(context);
    if (created == null) return;
    await store.addToPlaylist(created.id, videoId);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.charcoal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add to playlist', style: AppTheme.elMessiri(size: 18, color: AppColors.gold)),
              const SizedBox(height: 8),
              ...store.playlists.map(
                (playlist) => ListTile(
                  leading: const Icon(Icons.queue_play_next_rounded, color: AppColors.gold),
                  title: Text(playlist.name, style: AppTheme.cairo(weight: FontWeight.w600)),
                  subtitle: Text('${playlist.videoIds.length} videos', style: AppTheme.cairo(size: 12, color: AppColors.muted)),
                  onTap: () async {
                    await store.addToPlaylist(playlist.id, videoId);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_rounded, color: AppColors.goldSoft),
                title: Text('New playlist', style: AppTheme.cairo(weight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final created = await promptCreatePlaylist(context);
                  if (created == null) return;
                  await store.addToPlaylist(created.id, videoId);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<Playlist?> promptCreatePlaylist(BuildContext context) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text('New playlist', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTheme.cairo(size: 15),
          decoration: const InputDecoration(hintText: 'Evening watchlist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTheme.cairo(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text('Create', style: AppTheme.cairo(color: AppColors.gold, weight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (name == null) return null;
  return LibraryStore.instance.createPlaylist(name);
}
