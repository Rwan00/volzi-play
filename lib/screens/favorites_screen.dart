import 'package:flutter/material.dart';

import '../services/library_store.dart';
import '../widgets/add_video_sheet.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/shell_header.dart';
import '../widgets/video_tile.dart';
import '../theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NightBackdrop(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (context, _) {
            final favorites = LibraryStore.instance.favorites;
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              children: [
                ShellHeader(
                  title: 'Saved',
                  action: IconButton(
                    onPressed: () => showAddVideoSheet(context),
                    icon: const Icon(Icons.add_rounded, color: AppColors.gold),
                  ),
                ),
                if (favorites.isEmpty)
                  const EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No favorites yet',
                    message: 'Heart a video from the library or the player to keep a short list of what you want to revisit.',
                  )
                else
                  ...favorites.map((video) => VideoTile(video: video)),
              ],
            );
          },
        ),
      ),
    );
  }
}
