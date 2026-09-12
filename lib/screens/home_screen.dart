import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_copy.dart';
import '../services/recent_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/video_link.dart';
import '../widgets/atmosphere.dart';
import '../widgets/brand_mark.dart';
import '../widgets/gold_button.dart';
import '../widgets/volzi_drawer.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _error;
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final items = await RecentStore.load();
    if (mounted) setState(() => _recent = items);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      _toast('Clipboard is empty.');
      return;
    }
    setState(() {
      _controller.text = text;
      _error = null;
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.graphite,
        content: Text(message, style: AppTheme.cairo(size: 14)),
      ),
    );
  }

  Future<void> _play([String? value]) async {
    final raw = VideoLink.normalize(value ?? _controller.text);
    final message = VideoLink.validationMessage(raw);
    setState(() {
      _controller.text = raw;
      _error = message;
    });
    if (message != null) return;
    _focus.unfocus();
    final next = await RecentStore.remember(raw);
    if (!mounted) return;
    setState(() => _recent = next);
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => PlayerScreen(url: raw),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const VolziDrawer(),
      body: NightBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 36),
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_rounded, color: AppColors.gold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppCopy.brand.toUpperCase(),
                    style: AppTheme.cinzel(size: 14, letterSpacing: 4),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 18),
              const Center(child: BrandMark(size: 92)),
              const SizedBox(height: 22),
              Text(
                'Enter a watch link',
                textAlign: TextAlign.center,
                style: AppTheme.elMessiri(size: 30, color: AppColors.gold),
              ),
              const SizedBox(height: 26),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.line),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focus,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.go,
                        autocorrect: false,
                        onSubmitted: (_) => _play(),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        style: AppTheme.cairo(size: 15, height: 1.5),
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
                      const SizedBox(height: 16),
                      GoldButton(
                        label: 'Play',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => _play(),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => _play(AppCopy.demoUrl),
                        icon: const Icon(Icons.auto_awesome_outlined, color: AppColors.goldSoft, size: 18),
                        label: Text(
                          'Play sample video',
                          style: AppTheme.cairo(size: 15, weight: FontWeight.w600, color: AppColors.goldSoft),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const GoldHairline(),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text('Recents on this device', style: AppTheme.elMessiri(size: 20)),
                  const Spacer(),
                  if (_recent.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await RecentStore.clear();
                        if (mounted) setState(() => _recent = []);
                      },
                      child: Text('Clear', style: AppTheme.cairo(size: 13, color: AppColors.gold)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_recent.isEmpty)
                Text(
                  'No links are saved until you play the first video. Recents stay on this device only.',
                  style: AppTheme.cairo(size: 14, color: AppColors.muted, height: 1.8),
                )
              else
                ..._recent.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppColors.line),
                      ),
                      tileColor: AppColors.graphite,
                      leading: const Icon(Icons.history_rounded, color: AppColors.gold),
                      title: Text(
                        VideoLink.formatLabel(url),
                        style: AppTheme.cairo(size: 13, color: AppColors.goldSoft, weight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.cairo(size: 13, color: AppColors.muted),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 18),
                        onPressed: () async {
                          final next = await RecentStore.remove(url);
                          if (mounted) setState(() => _recent = next);
                        },
                      ),
                      onTap: () => _play(url),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
