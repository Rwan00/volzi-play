class Playlist {
  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    List<String>? videoIds,
  }) : videoIds = videoIds ?? [];

  final String id;
  String name;
  final DateTime createdAt;
  final List<String> videoIds;

  Playlist copyWith({String? name, List<String>? videoIds}) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      videoIds: videoIds ?? List<String>.from(this.videoIds),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'videoIds': videoIds,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Playlist',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      videoIds: ((json['videoIds'] as List?) ?? const []).whereType<String>().toList(),
    );
  }
}
