import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_copy.dart';
import '../models/library_video.dart';
import '../models/playlist.dart';
import '../utils/video_link.dart';

class LibraryStore extends ChangeNotifier {
  LibraryStore._();

  static final LibraryStore instance = LibraryStore._();

  static const _libraryKey = 'volzi.library.videos.v1';
  static const _playlistsKey = 'volzi.library.playlists.v1';
  static const _legacyRecentKey = 'volzi.recent.urls';

  final List<LibraryVideo> _videos = [];
  final List<Playlist> _playlists = [];
  bool loaded = false;

  List<LibraryVideo> get videos => List.unmodifiable(_videos);
  List<Playlist> get playlists => List.unmodifiable(_playlists);

  List<LibraryVideo> get favorites =>
      _videos.where((video) => video.favorite).toList(growable: false);

  List<LibraryVideo> get history {
    final items = _videos.where((video) => video.lastPlayedAt != null).toList()
      ..sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));
    return items;
  }

  List<LibraryVideo> get continueWatching {
    final items = _videos.where((video) => video.canResume).toList()
      ..sort((a, b) => (b.lastPlayedAt ?? b.addedAt).compareTo(a.lastPlayedAt ?? a.addedAt));
    return items;
  }

  List<LibraryVideo> get recentlyAdded {
    final items = [..._videos]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return items;
  }

  LibraryVideo? byId(String id) {
    for (final video in _videos) {
      if (video.id == id) return video;
    }
    return null;
  }

  Playlist? playlistById(String id) {
    for (final playlist in _playlists) {
      if (playlist.id == id) return playlist;
    }
    return null;
  }

  List<LibraryVideo> videosIn(Playlist playlist) {
    return playlist.videoIds.map(byId).whereType<LibraryVideo>().toList(growable: false);
  }

  List<LibraryVideo> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return recentlyAdded;
    return _videos.where((video) {
      return video.title.toLowerCase().contains(needle) ||
          video.url.toLowerCase().contains(needle) ||
          video.format.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  Future<void> load() async {
    if (loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawVideos = prefs.getString(_libraryKey);
    if (rawVideos != null && rawVideos.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawVideos) as List<dynamic>;
        _videos
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map((item) => LibraryVideo.fromJson(Map<String, dynamic>.from(item))),
          );
      } catch (_) {
        _videos.clear();
      }
    }

    final rawPlaylists = prefs.getString(_playlistsKey);
    if (rawPlaylists != null && rawPlaylists.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPlaylists) as List<dynamic>;
        _playlists
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map((item) => Playlist.fromJson(Map<String, dynamic>.from(item))),
          );
      } catch (_) {
        _playlists.clear();
      }
    }

    final legacy = prefs.getStringList(_legacyRecentKey) ?? const <String>[];
    for (final url in legacy.reversed) {
      await addFromUrl(url, persist: false);
    }
    if (_videos.isEmpty) {
      await addFromUrl(
        AppCopy.demoUrl,
        title: 'Sample HLS stream',
        persist: false,
      );
    }
    loaded = true;
    await _persist();
  }

  Future<LibraryVideo> addFromUrl(String raw, {String? title, bool persist = true}) async {
    final url = VideoLink.normalize(raw);
    final existing = _videos.cast<LibraryVideo?>().firstWhere(
          (video) => video?.url == url,
          orElse: () => null,
        );
    if (existing != null) {
      if (title != null && title.trim().isNotEmpty && existing.title != title.trim()) {
        existing.title = title.trim();
        if (persist) await _persist();
      }
      return existing;
    }
    final video = LibraryVideo(
      id: 'v_${DateTime.now().microsecondsSinceEpoch}',
      url: url,
      title: (title ?? VideoLink.suggestedTitle(url)).trim(),
      addedAt: DateTime.now(),
    );
    _videos.insert(0, video);
    if (persist) await _persist();
    return video;
  }

  Future<void> rename(String id, String title) async {
    final video = byId(id);
    if (video == null) return;
    final next = title.trim();
    if (next.isEmpty) return;
    video.title = next;
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    final video = byId(id);
    if (video == null) return;
    video.favorite = !video.favorite;
    await _persist();
  }

  Future<void> removeVideo(String id) async {
    _videos.removeWhere((video) => video.id == id);
    for (final playlist in _playlists) {
      playlist.videoIds.remove(id);
    }
    await _persist();
  }

  Future<void> markPlayed({
    required String id,
    required int positionMs,
    required int durationMs,
    bool completed = false,
  }) async {
    final video = byId(id);
    if (video == null) return;
    video.lastPlayedAt = DateTime.now();
    video.lastPositionMs = positionMs < 0 ? 0 : positionMs;
    if (durationMs > 0) video.durationMs = durationMs;
    if (completed) {
      video.completed = true;
      video.lastPositionMs = 0;
    }
    await _persist();
  }

  Future<void> bumpPlayCount(String id) async {
    final video = byId(id);
    if (video == null) return;
    video.playCount += 1;
    video.lastPlayedAt = DateTime.now();
    video.completed = false;
    await _persist();
  }

  Future<Playlist> createPlaylist(String name) async {
    final playlist = Playlist(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'New playlist' : name.trim(),
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, playlist);
    await _persist();
    return playlist;
  }

  Future<void> renamePlaylist(String id, String name) async {
    final playlist = playlistById(id);
    if (playlist == null) return;
    final next = name.trim();
    if (next.isEmpty) return;
    playlist.name = next;
    await _persist();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((playlist) => playlist.id == id);
    await _persist();
  }

  Future<void> addToPlaylist(String playlistId, String videoId) async {
    final playlist = playlistById(playlistId);
    if (playlist == null || byId(videoId) == null) return;
    if (playlist.videoIds.contains(videoId)) return;
    playlist.videoIds.add(videoId);
    await _persist();
  }

  Future<void> removeFromPlaylist(String playlistId, String videoId) async {
    final playlist = playlistById(playlistId);
    if (playlist == null) return;
    playlist.videoIds.remove(videoId);
    await _persist();
  }

  Future<void> moveInPlaylist(String playlistId, String videoId, int offset) async {
    final playlist = playlistById(playlistId);
    if (playlist == null) return;
    final index = playlist.videoIds.indexOf(videoId);
    final next = index + offset;
    if (index < 0 || next < 0 || next >= playlist.videoIds.length) return;
    final id = playlist.videoIds.removeAt(index);
    playlist.videoIds.insert(next, id);
    await _persist();
  }

  String? nextInPlaylist(String playlistId, String videoId) {
    final playlist = playlistById(playlistId);
    if (playlist == null) return null;
    final index = playlist.videoIds.indexOf(videoId);
    if (index < 0 || index + 1 >= playlist.videoIds.length) return null;
    return playlist.videoIds[index + 1];
  }

  String? previousInPlaylist(String playlistId, String videoId) {
    final playlist = playlistById(playlistId);
    if (playlist == null) return null;
    final index = playlist.videoIds.indexOf(videoId);
    if (index <= 0) return null;
    return playlist.videoIds[index - 1];
  }

  Future<void> clearHistory() async {
    for (final video in _videos) {
      video.lastPlayedAt = null;
      video.lastPositionMs = 0;
      video.completed = false;
    }
    await _persist();
  }

  Future<void> clearAll() async {
    _videos.clear();
    _playlists.clear();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _libraryKey,
      jsonEncode(_videos.map((video) => video.toJson()).toList()),
    );
    await prefs.setString(
      _playlistsKey,
      jsonEncode(_playlists.map((playlist) => playlist.toJson()).toList()),
    );
    notifyListeners();
  }
}
