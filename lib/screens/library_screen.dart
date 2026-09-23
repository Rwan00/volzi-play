import 'package:flutter/material.dart';

import '../models/library_video.dart';
import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/add_video_sheet.dart';
import '../widgets/atmosphere.dart';
import '../widgets/empty_state.dart';
import '../widgets/shell_header.dart';
import '../widgets/video_tile.dart';

enum _LibrarySort { newest, title, unfinished, mostPlayed }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _query = TextEditingController();
  _LibrarySort _sort = _LibrarySort.newest;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<LibraryVideo> _items(LibraryStore store) {
    final searched = store.search(_query.text);
    return switch (_sort) {
      _LibrarySort.newest => [...searched]..sort((a, b) => b.addedAt.compareTo(a.addedAt)),
      _LibrarySort.title => [...searched]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())),
      _LibrarySort.unfinished => searched.where((video) => video.canResume).toList(),
      _LibrarySort.mostPlayed => [...searched]..sort((a, b) => b.playCount.compareTo(a.playCount)),
    };
  }

  @override
  Widget build(BuildContext context) {
    return NightBackdrop(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: LibraryStore.instance,
          builder: (context, _) {
            final store = LibraryStore.instance;
            final items = _items(store);
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              children: [
                ShellHeader(
                  title: 'Library',
                  action: IconButton(
                    tooltip: 'Add video',
                    onPressed: () => showAddVideoSheet(context),
                    icon: const Icon(Icons.add_rounded, color: AppColors.gold),
                  ),
                ),
                TextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  style: AppTheme.cairo(size: 15),
                  decoration: const InputDecoration(
                    hintText: 'Search titles or links',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SortChip(label: 'Newest', selected: _sort == _LibrarySort.newest, onTap: () => setState(() => _sort = _LibrarySort.newest)),
                      _SortChip(label: 'Title', selected: _sort == _LibrarySort.title, onTap: () => setState(() => _sort = _LibrarySort.title)),
                      _SortChip(label: 'Unfinished', selected: _sort == _LibrarySort.unfinished, onTap: () => setState(() => _sort = _LibrarySort.unfinished)),
                      _SortChip(label: 'Most played', selected: _sort == _LibrarySort.mostPlayed, onTap: () => setState(() => _sort = _LibrarySort.mostPlayed)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const EmptyState(
                    icon: Icons.video_library_outlined,
                    title: 'Nothing here yet',
                    message: 'Add a playable link to start a personal library you can search, sort, and resume.',
                  )
                else
                  ...items.map((video) => VideoTile(video: video)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.gold,
        backgroundColor: AppColors.graphite,
        labelStyle: AppTheme.cairo(
          size: 13,
          weight: FontWeight.w600,
          color: selected ? AppColors.night : AppColors.cream,
        ),
        side: const BorderSide(color: AppColors.line),
      ),
    );
  }
}
