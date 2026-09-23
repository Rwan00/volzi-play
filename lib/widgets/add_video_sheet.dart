import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_copy.dart';
import '../services/library_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/play_route.dart';
import '../utils/video_link.dart';
import 'gold_button.dart';

Future<void> showAddVideoSheet(BuildContext context, {bool playAfterSave = false}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.charcoal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: _AddVideoForm(playAfterSave: playAfterSave),
      );
    },
  );
}

class _AddVideoForm extends StatefulWidget {
  const _AddVideoForm({required this.playAfterSave});

  final bool playAfterSave;

  @override
  State<_AddVideoForm> createState() => _AddVideoFormState();
}

class _AddVideoFormState extends State<_AddVideoForm> {
  final _url = TextEditingController();
  final _title = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _url.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() {
      _url.text = text;
      _error = null;
      if (_title.text.trim().isEmpty) {
        _title.text = VideoLink.suggestedTitle(text);
      }
    });
  }

  Future<void> _save({required bool play}) async {
    final raw = VideoLink.normalize(_url.text);
    final message = VideoLink.validationMessage(raw);
    setState(() => _error = message);
    if (message != null) return;
    setState(() => _busy = true);
    final video = await LibraryStore.instance.addFromUrl(
      raw,
      title: _title.text.trim().isEmpty ? null : _title.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context);
    if (play || widget.playAfterSave) {
      await openPlayer(context, videoId: video.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add to library', style: AppTheme.elMessiri(size: 22, color: AppColors.gold)),
            const SizedBox(height: 6),
            Text(
              'Save an M3U8, MP4, or other playable link. You can rename it, favorite it, and add it to playlists.',
              textAlign: TextAlign.center,
              style: AppTheme.cairo(size: 13, color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              autocorrect: false,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              style: AppTheme.cairo(size: 15),
              decoration: InputDecoration(
                hintText: 'https://example.com/stream.m3u8',
                errorText: _error,
                prefixIcon: const Icon(Icons.link_rounded, color: AppColors.gold),
                suffixIcon: IconButton(
                  tooltip: 'Paste',
                  onPressed: _paste,
                  icon: const Icon(Icons.content_paste_rounded, color: AppColors.goldSoft),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              style: AppTheme.cairo(size: 15),
              decoration: const InputDecoration(
                hintText: 'Optional title',
                prefixIcon: Icon(Icons.title_rounded, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 16),
            GoldButton(
              label: 'Save and play',
              icon: Icons.play_arrow_rounded,
              onPressed: _busy ? null : () => _save(play: true),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy ? null : () => _save(play: false),
              child: Text('Save only', style: AppTheme.cairo(color: AppColors.goldSoft, weight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      _url.text = AppCopy.demoUrl;
                      _title.text = 'Sample HLS stream';
                      _save(play: true);
                    },
              child: Text('Use sample stream', style: AppTheme.cairo(size: 13, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
