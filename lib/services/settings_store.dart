import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_settings.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore._();

  static final SettingsStore instance = SettingsStore._();
  static const _key = 'volzi.player.settings.v1';

  PlayerSettings settings = const PlayerSettings();
  bool loaded = false;

  Future<void> load() async {
    if (loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        settings = PlayerSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        settings = const PlayerSettings();
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> update(PlayerSettings next) async {
    settings = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(next.toJson()));
    notifyListeners();
  }
}
