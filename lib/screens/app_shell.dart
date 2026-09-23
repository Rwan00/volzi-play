import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/volzi_drawer.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'playlists_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const VolziDrawer(),
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          LibraryScreen(),
          PlaylistsScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.ink,
          indicatorColor: AppColors.graphite,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return AppTheme.cairo(
              size: 12,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.gold : AppColors.muted,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? AppColors.gold : AppColors.muted);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library_rounded), label: 'Library'),
            NavigationDestination(icon: Icon(Icons.queue_play_next_outlined), selectedIcon: Icon(Icons.queue_play_next_rounded), label: 'Playlists'),
            NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Saved'),
          ],
        ),
      ),
    );
  }
}
