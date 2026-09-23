import '../utils/video_link.dart';

class LibraryVideo {
  LibraryVideo({
    required this.id,
    required this.url,
    required this.title,
    required this.addedAt,
    this.lastPlayedAt,
    this.lastPositionMs = 0,
    this.durationMs = 0,
    this.playCount = 0,
    this.favorite = false,
    this.completed = false,
  });

  final String id;
  final String url;
  String title;
  final DateTime addedAt;
  DateTime? lastPlayedAt;
  int lastPositionMs;
  int durationMs;
  int playCount;
  bool favorite;
  bool completed;

  bool get isLive => durationMs <= 0;

  bool get canResume {
    if (isLive || completed) return false;
    return lastPositionMs >= 3000 && (durationMs == 0 || lastPositionMs < durationMs - 4000);
  }

  double get progress {
    if (durationMs <= 0) return 0;
    return (lastPositionMs / durationMs).clamp(0.0, 1.0);
  }

  String get format => VideoLink.formatLabel(url);

  LibraryVideo copyWith({
    String? title,
    DateTime? lastPlayedAt,
    int? lastPositionMs,
    int? durationMs,
    int? playCount,
    bool? favorite,
    bool? completed,
    bool clearLastPlayed = false,
  }) {
    return LibraryVideo(
      id: id,
      url: url,
      title: title ?? this.title,
      addedAt: addedAt,
      lastPlayedAt: clearLastPlayed ? null : (lastPlayedAt ?? this.lastPlayedAt),
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      durationMs: durationMs ?? this.durationMs,
      playCount: playCount ?? this.playCount,
      favorite: favorite ?? this.favorite,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'addedAt': addedAt.toIso8601String(),
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
        'lastPositionMs': lastPositionMs,
        'durationMs': durationMs,
        'playCount': playCount,
        'favorite': favorite,
        'completed': completed,
      };

  factory LibraryVideo.fromJson(Map<String, dynamic> json) {
    return LibraryVideo(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String? ?? 'Untitled',
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      lastPlayedAt: DateTime.tryParse(json['lastPlayedAt'] as String? ?? ''),
      lastPositionMs: (json['lastPositionMs'] as num?)?.toInt() ?? 0,
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      favorite: json['favorite'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
