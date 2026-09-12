import 'package:shared_preferences/shared_preferences.dart';

class RecentStore {
  RecentStore._();

  static const _key = 'volzi.recent.urls';
  static const _limit = 8;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  static Future<List<String>> remember(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final current = [...?prefs.getStringList(_key)];
    current.remove(url);
    current.insert(0, url);
    final next = current.take(_limit).toList();
    await prefs.setStringList(_key, next);
    return next;
  }

  static Future<List<String>> remove(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final current = [...?prefs.getStringList(_key)]..remove(url);
    await prefs.setStringList(_key, current);
    return current;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
