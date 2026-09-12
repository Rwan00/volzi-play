import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/video_link.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.url});

  final String url;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;
  bool _controls = true;
  bool _cinema = false;
  Timer? _hide;
  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _boot();
  }

  Future<void> _boot() async {
    final uri = VideoLink.tryParse(widget.url);
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
      await controller.play();
      controller.addListener(_tick);
      if (!mounted) return;
      setState(() {
        _ready = true;
        _error = null;
      });
      _scheduleHide();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            'Could not prepare the video. Check the link, format, and network connection.\n$error';
      });
    }
  }

  void _tick() {
    if (mounted) setState(() {});
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

  Future<void> _leave() async {
    await _setCinema(false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _hide?.cancel();
    _controller?.removeListener(_tick);
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

  String _clock(Duration value) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    if (hours > 0) return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final value = controller?.value;
    final aspect = (value?.isInitialized ?? false) && value!.aspectRatio > 0
        ? value.aspectRatio
        : 16 / 9;

    return Scaffold(
      backgroundColor: AppColors.night,
      appBar: _cinema
          ? null
          : AppBar(
              leading: IconButton(
                onPressed: _leave,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: Text(VideoLink.formatLabel(widget.url)),
            ),
      body: GestureDetector(
        onTap: () {
          setState(() => _controls = !_controls);
          if (_controls) _scheduleHide();
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
                  onBack: _leave,
                  onCinema: () => _setCinema(!_cinema),
                  onSpeed: () => _pickSpeed(controller),
                  clock: _clock,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Playback speed', style: AppTheme.elMessiri(size: 20, color: AppColors.gold)),
                const SizedBox(height: 12),
                ..._speeds.map(
                  (speed) => ListTile(
                    title: Text(
                      speed == 1 ? 'Normal  1x' : '${speed}x',
                      style: AppTheme.cairo(weight: FontWeight.w600),
                    ),
                    trailing: controller.value.playbackSpeed == speed
                        ? const Icon(Icons.check_rounded, color: AppColors.gold)
                        : null,
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
    _scheduleHide();
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
              TextButton(
                onPressed: onBack,
                child: Text('Back to the link', style: AppTheme.cairo(color: AppColors.gold)),
              ),
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
    required this.onBack,
    required this.onCinema,
    required this.onSpeed,
    required this.clock,
  });

  final VideoPlayerController controller;
  final bool cinema;
  final VoidCallback onBack;
  final VoidCallback onCinema;
  final VoidCallback onSpeed;
  final String Function(Duration) clock;

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
              Colors.black.withValues(alpha: 0.72),
            ],
            stops: const [0, 0.45, 1],
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
                    const Spacer(),
                    TextButton(
                      onPressed: onSpeed,
                      child: Text(
                        '${value.playbackSpeed}x',
                        style: AppTheme.cinzel(size: 12, letterSpacing: 1, color: AppColors.gold),
                      ),
                    ),
                    IconButton(
                      onPressed: onCinema,
                      icon: Icon(
                        cinema ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  value.isPlaying ? controller.pause() : controller.play();
                },
                iconSize: 74,
                icon: Icon(
                  value.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                  color: AppColors.gold,
                ),
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
                          max: duration.toDouble(),
                          value: position.clamp(0, duration).toDouble(),
                          onChanged: (next) {
                            controller.seekTo(Duration(milliseconds: next.round()));
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            clock(value.position),
                            style: AppTheme.cairo(size: 12, color: AppColors.goldSoft),
                          ),
                          const Spacer(),
                          Text(
                            clock(value.duration),
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
