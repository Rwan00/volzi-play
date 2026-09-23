import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/library_video.dart';
import '../services/library_store.dart';
import '../services/settings_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import '../utils/video_link.dart';
import '../widgets/video_tile.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.videoId, this.playlistId});

  final String videoId;
  final String? playlistId;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  VideoPlayerController? _controller;
  LibraryVideo? _video;
  bool _ready = false;
  String? _error;
  bool _controls = true;
  bool _cinema = false;
  bool _loop = false;
  bool _ended = false;
  Timer? _hide;
  Timer? _sleep;
  Duration? _sleepLeft;
  Timer? _sleepTick;
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _boot();
  }

  Future<void> _boot() async {
    final video = LibraryStore.instance.byId(widget.videoId);
    if (video == null) {
      setState(() => _error = 'This video is no longer in your library.');
      return;
    }
    _video = video;
    final uri = VideoLink.tryParse(video.url);
    if (uri == null) {
      setState(() => _error = 'Could not read that link.');
      return;
    }
    final controller = VideoPlayerController.networkUrl(
      uri,
      httpHeaders: const {
        'User-Agent': 'VolziPlay/1.0 (iOS)',
        'Accept': '*/*',
      },
    );
    _controller = controller;
    try {
      await controller.initialize();
      final settings = SettingsStore.instance.settings;
      await controller.setPlaybackSpeed(settings.defaultSpeed);
      final durationMs = controller.value.duration.inMilliseconds;
      if (settings.rememberPosition && durationMs > 0 && video.lastPositionMs >= 3000 && video.lastPositionMs < durationMs - 4000) {
        await controller.seekTo(Duration(milliseconds: video.lastPositionMs));
      }
      await controller.setLooping(_loop);
      await controller.play();
      await LibraryStore.instance.bumpPlayCount(video.id);
      controller.addListener(_tick);
      if (!mounted) return;
      setState(() {
        _ready = true;
        _error = null;
        _video = LibraryStore.instance.byId(video.id);
      });
      _scheduleHide();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not prepare the video. Check the link, format, and network connection.\n$error';
      });
    }
  }

  void _tick() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    setState(() {});
    _maybeSave();
    final value = controller.value;
    if (_ended || _loop || !value.isInitialized) return;
    final duration = value.duration.inMilliseconds;
    if (duration > 0 && value.position.inMilliseconds >= duration - 450) {
      _ended = true;
      _onEnded();
    }
  }

  Future<void> _onEnded() async {
    await _persist(completed: true);
    final settings = SettingsStore.instance.settings;
    final playlistId = widget.playlistId;
    if (!settings.autoplayNext || playlistId == null) return;
    final nextId = LibraryStore.instance.nextInPlaylist(playlistId, widget.videoId);
    if (nextId == null || !mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => PlayerScreen(videoId: nextId, playlistId: playlistId),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _maybeSave() {
    final now = DateTime.now();
    if (now.difference(_lastSave).inSeconds < 3) return;
    _lastSave = now;
    _persist();
  }

  Future<void> _persist({bool completed = false}) async {
    final video = _video;
    final value = _controller?.value;
    if (video == null || value == null || !value.isInitialized) return;
    await LibraryStore.instance.markPlayed(
      id: video.id,
      positionMs: value.position.inMilliseconds,
      durationMs: value.duration.inMilliseconds,
      completed: completed,
    );
  }

  void _scheduleHide() {
    _hide?.cancel();
    _hide = Timer(const Duration(seconds: 4), () {
      if (!mounted || !(_controller?.value.isPlaying ?? false)) return;
      setState(() => _controls = false);
    });
  }

  Future<void> _setCinema(bool value) async {
    setState(() => _cinema = value);
    if (value) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _skip(int direction) async {
    final controller = _controller;
    if (controller == null) return;
    final skip = SettingsStore.instance.settings.skipSeconds;
    var next = controller.value.position + Duration(seconds: skip * direction);
    if (next.isNegative) next = Duration.zero;
    final duration = controller.value.duration;
    if (duration > Duration.zero && next > duration) next = duration;
    await controller.seekTo(next);
    _scheduleHide();
  }

  Future<void> _toggleLoop() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _loop = !_loop);
    await controller.setLooping(_loop);
    _ended = false;
  }

  void _setSleep(Duration duration) {
    _sleep?.cancel();
    _sleepTick?.cancel();
    setState(() => _sleepLeft = duration);
    _sleep = Timer(duration, () async {
      await _controller?.pause();
      await _persist();
      if (!mounted) return;
      setState(() => _sleepLeft = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.graphite, content: Text('Sleep timer ended', style: AppTheme.cairo(size: 14))),
      );
    });
    _sleepTick = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _sleepLeft;
      if (left == null) return;
      final next = left - const Duration(seconds: 1);
      if (!mounted) return;
      setState(() => _sleepLeft = next.isNegative ? Duration.zero : next);
    });
  }

  Future<void> _leave() async {
    await _persist();
    await _setCinema(false);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openRelative(String? id) async {
    if (id == null) return;
    await _persist();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => PlayerScreen(videoId: id, playlistId: widget.playlistId),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _persist();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hide?.cancel();
    _sleep?.cancel();
    _sleepTick?.cancel();
    _controller?.removeListener(_tick);
    final video = _video;
    final value = _controller?.value;
    if (video != null && value != null && value.isInitialized) {
      LibraryStore.instance.markPlayed(
        id: video.id,
        positionMs: value.position.inMilliseconds,
        durationMs: value.duration.inMilliseconds,
      );
    }
    _controller?.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final value = controller?.value;
    final aspect = (value?.isInitialized ?? false) && value!.aspectRatio > 0 ? value.aspectRatio : 16 / 9;
    final video = _video ?? LibraryStore.instance.byId(widget.videoId);
    final previous = widget.playlistId == null ? null : LibraryStore.instance.previousInPlaylist(widget.playlistId!, widget.videoId);
    final next = widget.playlistId == null ? null : LibraryStore.instance.nextInPlaylist(widget.playlistId!, widget.videoId);

    return Scaffold(
      backgroundColor: AppColors.night,
      appBar: _cinema
          ? null
          : AppBar(
              leading: IconButton(onPressed: _leave, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              title: Text(video?.title ?? VideoLink.formatLabel(widget.videoId)),
              actions: [
                if (video != null)
                  IconButton(
                    onPressed: () async {
                      await LibraryStore.instance.toggleFavorite(video.id);
                      if (mounted) setState(() => _video = LibraryStore.instance.byId(video.id));
                    },
                    icon: Icon(video.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.gold),
                  ),
                if (video != null)
                  IconButton(
                    onPressed: () => showVideoActions(context, video, playlistId: widget.playlistId),
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
              ],
            ),
      body: GestureDetector(
        onTap: () {
          setState(() => _controls = !_controls);
          if (_controls) _scheduleHide();
        },
        onDoubleTapDown: (details) {
          final width = MediaQuery.sizeOf(context).width;
          _skip(details.localPosition.dx < width / 2 ? -1 : 1);
        },
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_ready && controller != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: aspect,
                    child: VideoPlayer(controller),
                  ),
                )
              else if (_error == null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.gold),
                    const SizedBox(height: 18),
                    Text('Preparing', style: AppTheme.elMessiri(size: 18, color: AppColors.goldSoft)),
                  ],
                ),
              if (_error != null) _ErrorCard(message: _error!, onBack: _leave),
              if (_ready && _controls && controller != null)
                _Controls(
                  controller: controller,
                  cinema: _cinema,
                  loop: _loop,
                  sleepLeft: _sleepLeft,
                  hasPrevious: previous != null,
                  hasNext: next != null,
                  skipSeconds: SettingsStore.instance.settings.skipSeconds,
                  onBack: _leave,
                  onCinema: () => _setCinema(!_cinema),
                  onSpeed: () => _pickSpeed(controller),
                  onLoop: _toggleLoop,
                  onSleep: () => _pickSleep(),
                  onSkipBack: () => _skip(-1),
                  onSkipForward: () => _skip(1),
                  onPrevious: () => _openRelative(previous),
                  onNext: () => _openRelative(next),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSpeed(VideoPlayerController controller) async {
    final selected = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Playback speed', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
                ..._speeds.map(
                  (speed) => ListTile(
                    title: Text(speed == 1 ? 'Normal  1x' : '${speed}x', style: AppTheme.cairo(weight: FontWeight.w600)),
                    trailing: controller.value.playbackSpeed == speed ? const Icon(Icons.check_rounded, color: AppColors.gold) : null,
                    onTap: () => Navigator.pop(context, speed),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) return;
    await controller.setPlaybackSpeed(selected);
    await SettingsStore.instance.update(SettingsStore.instance.settings.copyWith(defaultSpeed: selected));
    _scheduleHide();
  }

  Future<void> _pickSleep() async {
    final selected = await showModalBottomSheet<Duration?>(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sleep timer', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
                ListTile(
                  title: Text('Off', style: AppTheme.cairo(weight: FontWeight.w600)),
                  onTap: () => Navigator.pop(context, Duration.zero),
                ),
                ...[5, 15, 30, 45, 60].map(
                  (minutes) => ListTile(
                    title: Text('$minutes minutes', style: AppTheme.cairo(weight: FontWeight.w600)),
                    onTap: () => Navigator.pop(context, Duration(minutes: minutes)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) return;
    if (selected == Duration.zero) {
      _sleep?.cancel();
      _sleepTick?.cancel();
      setState(() => _sleepLeft = null);
      return;
    }
    _setSleep(selected);
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, color: AppColors.gold, size: 36),
              const SizedBox(height: 12),
              Text('Playback failed', style: AppTheme.elMessiri(size: 22, color: AppColors.gold)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: AppTheme.cairo(size: 14, height: 1.8)),
              const SizedBox(height: 18),
              TextButton(onPressed: onBack, child: Text('Back to library', style: AppTheme.cairo(color: AppColors.gold))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.controller,
    required this.cinema,
    required this.loop,
    required this.sleepLeft,
    required this.hasPrevious,
    required this.hasNext,
    required this.skipSeconds,
    required this.onBack,
    required this.onCinema,
    required this.onSpeed,
    required this.onLoop,
    required this.onSleep,
    required this.onSkipBack,
    required this.onSkipForward,
    required this.onPrevious,
    required this.onNext,
  });

  final VideoPlayerController controller;
  final bool cinema;
  final bool loop;
  final Duration? sleepLeft;
  final bool hasPrevious;
  final bool hasNext;
  final int skipSeconds;
  final VoidCallback onBack;
  final VoidCallback onCinema;
  final VoidCallback onSpeed;
  final VoidCallback onLoop;
  final VoidCallback onSleep;
  final VoidCallback onSkipBack;
  final VoidCallback onSkipForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final position = value.position.inMilliseconds.toDouble();
    final durationMs = value.duration.inMilliseconds;
    final duration = durationMs <= 0 ? 1.0 : durationMs.toDouble();

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.78),
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.cream, size: 32),
                    ),
                    if (sleepLeft != null)
                      Text('Sleep ${TimeFormat.clock(sleepLeft!)}', style: AppTheme.cairo(size: 12, color: AppColors.goldSoft)),
                    const Spacer(),
                    TextButton(
                      onPressed: onSpeed,
                      child: Text('${value.playbackSpeed}x', style: AppTheme.cinzel(size: 12, letterSpacing: 1, color: AppColors.gold)),
                    ),
                    IconButton(
                      onPressed: onLoop,
                      icon: Icon(Icons.repeat_rounded, color: loop ? AppColors.gold : AppColors.cream),
                    ),
                    IconButton(
                      onPressed: onSleep,
                      icon: const Icon(Icons.bedtime_outlined, color: AppColors.cream),
                    ),
                    IconButton(
                      onPressed: onCinema,
                      icon: Icon(cinema ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, color: AppColors.cream),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: hasPrevious ? onPrevious : null,
                    icon: Icon(Icons.skip_previous_rounded, color: hasPrevious ? AppColors.cream : AppColors.muted, size: 34),
                  ),
                  IconButton(
                    onPressed: onSkipBack,
                    icon: const Icon(Icons.replay_10_rounded, color: AppColors.cream, size: 32),
                  ),
                  IconButton(
                    onPressed: () => value.isPlaying ? controller.pause() : controller.play(),
                    iconSize: 74,
                    icon: Icon(
                      value.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  IconButton(
                    onPressed: onSkipForward,
                    icon: const Icon(Icons.forward_10_rounded, color: AppColors.cream, size: 32),
                  ),
                  IconButton(
                    onPressed: hasNext ? onNext : null,
                    icon: Icon(Icons.skip_next_rounded, color: hasNext ? AppColors.cream : AppColors.muted, size: 34),
                  ),
                ],
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.gold,
                          inactiveTrackColor: AppColors.line,
                          thumbColor: AppColors.goldSoft,
                          overlayColor: AppColors.gold.withValues(alpha: 0.18),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          min: 0,
                          max: duration,
                          value: position.clamp(0, duration),
                          onChanged: (next) => controller.seekTo(Duration(milliseconds: next.round())),
                        ),
                      ),
                      Row(
                        children: [
                          Text(TimeFormat.clock(value.position), style: AppTheme.cairo(size: 12, color: AppColors.goldSoft)),
                          const Spacer(),
                          Text('±${skipSeconds}s', style: AppTheme.cairo(size: 11, color: AppColors.muted)),
                          const Spacer(),
                          Text(
                            value.duration > Duration.zero ? TimeFormat.clock(value.duration) : 'Live',
                            style: AppTheme.cairo(size: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
