import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import '../models/day_entry.dart';
import '../models/goal_settings.dart';

class StorageService {
  static const _dayDataKey = 'goal_path_day_data';
  static const _settingsKey = 'goal_path_settings';
  static const _darkModeKey = 'goal_path_dark_mode';
  static const _prefsKey = 'goal_path_app_prefs';

  Future<Map<String, DayEntry>> loadDayData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dayDataKey);
    if (raw == null) return {};

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (key, value) => MapEntry(
          key,
          DayEntry.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDayData(Map<String, DayEntry> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = data.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_dayDataKey, jsonEncode(encoded));
  }

  Future<GoalSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return GoalSettings.defaults();

    try {
      return GoalSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return GoalSettings.defaults();
    }
  }

  Future<void> saveSettings(GoalSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<AppPreferences> loadAppPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return const AppPreferences();
    try {
      return AppPreferences.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const AppPreferences();
    }
  }

  Future<void> saveAppPreferences(AppPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(value.toJson()));
  }
}
