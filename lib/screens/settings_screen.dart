import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../services/library_store.dart';
import '../services/settings_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/atmosphere.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playback settings')),
      body: NightBackdrop(
        child: ListenableBuilder(
          listenable: SettingsStore.instance,
          builder: (context, _) {
            final store = SettingsStore.instance;
            final settings = store.settings;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Text('These controls stay on this device and apply to every video.', style: AppTheme.cairo(size: 14, color: AppColors.muted, height: 1.7)),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  value: settings.rememberPosition,
                  activeThumbColor: AppColors.gold,
                  title: Text('Resume playback', style: AppTheme.cairo(weight: FontWeight.w700)),
                  subtitle: Text('Continue unfinished videos from the last second you watched.', style: AppTheme.cairo(size: 13, color: AppColors.muted)),
                  onChanged: (value) => store.update(settings.copyWith(rememberPosition: value)),
                ),
                SwitchListTile.adaptive(
                  value: settings.autoplayNext,
                  activeThumbColor: AppColors.gold,
                  title: Text('Autoplay next in playlist', style: AppTheme.cairo(weight: FontWeight.w700)),
                  subtitle: Text('When a playlist item ends, start the next one automatically.', style: AppTheme.cairo(size: 13, color: AppColors.muted)),
                  onChanged: (value) => store.update(settings.copyWith(autoplayNext: value)),
                ),
                const SizedBox(height: 8),
                Text('Default speed', style: AppTheme.elMessiri(size: 18)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                    final selected = settings.defaultSpeed == speed;
                    return ChoiceChip(
                      label: Text(speed == 1 ? '1x' : '${speed}x'),
                      selected: selected,
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.graphite,
                      labelStyle: AppTheme.cairo(size: 13, weight: FontWeight.w700, color: selected ? AppColors.night : AppColors.cream),
                      onSelected: (_) => store.update(settings.copyWith(defaultSpeed: speed)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text('Skip interval', style: AppTheme.elMessiri(size: 18)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [10, 15, 30].map((seconds) {
                    final selected = settings.skipSeconds == seconds;
                    return ChoiceChip(
                      label: Text('${seconds}s'),
                      selected: selected,
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.graphite,
                      labelStyle: AppTheme.cairo(size: 13, weight: FontWeight.w700, color: selected ? AppColors.night : AppColors.cream),
                      onSelected: (_) => store.update(settings.copyWith(skipSeconds: seconds)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.line)),
                  tileColor: AppColors.graphite,
                  title: Text('Clear watch history', style: AppTheme.cairo(weight: FontWeight.w700)),
                  onTap: () => LibraryStore.instance.clearHistory(),
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.line)),
                  tileColor: AppColors.graphite,
                  title: Text('Reset library', style: AppTheme.cairo(weight: FontWeight.w700, color: AppColors.danger)),
                  subtitle: Text('Removes videos, playlists, and favorites from this device.', style: AppTheme.cairo(size: 13, color: AppColors.muted)),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          backgroundColor: AppColors.charcoal,
                          title: Text('Reset library?', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
                          content: Text('This cannot be undone.', style: AppTheme.cairo(size: 14, color: AppColors.muted)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('Cancel', style: AppTheme.cairo(color: AppColors.muted))),
                            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('Reset', style: AppTheme.cairo(color: AppColors.danger))),
                          ],
                        );
                      },
                    );
                    if (ok == true) await LibraryStore.instance.clearAll();
                  },
                ),
                const SizedBox(height: 22),
                Text('Volzi Play ${AppCopy.version}', textAlign: TextAlign.center, style: AppTheme.cairo(size: 12, color: AppColors.muted)),
              ],
            );
          },
        ),
      ),
    );
  }
}
