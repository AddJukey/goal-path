import 'package:flutter/foundation.dart';

import '../demo/demo_seed.dart';
import '../models/app_preferences.dart';
import '../models/day_entry.dart';
import '../models/goal_settings.dart';
import '../services/goal_calculator.dart';
import '../services/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider(this._storage);

  final StorageService _storage;

  GoalSettings _settings = GoalSettings.defaults();
  Map<String, DayEntry> _dayData = {};
  AppPreferences _appPreferences = const AppPreferences();
  bool _isDarkMode = true;
  bool _isLoading = true;

  GoalSettings get settings => _settings;
  Map<String, DayEntry> get dayData => Map.unmodifiable(_dayData);
  AppPreferences get appPreferences => _appPreferences;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  GoalCalculator get calculator => GoalCalculator(
        settings: _settings,
        dayData: _dayData,
      );

  static const _demoMode = bool.fromEnvironment('DEMO_MODE');

  Future<void> init() async {
    try {
      if (_demoMode) {
        _settings = DemoSeed.settings();
        _dayData = DemoSeed.dayData();
        _isDarkMode = true;
        await _storage.saveSettings(_settings);
        await _storage.saveDayData(_dayData);
        await _storage.saveDarkMode(_isDarkMode);
      } else {
        _settings = await _storage.loadSettings();
        _dayData = await _storage.loadDayData();
        _isDarkMode = await _storage.loadDarkMode();
        _appPreferences = await _storage.loadAppPreferences();
      }
    } catch (e) {
      debugPrint('GoalProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(GoalSettings settings) async {
    _settings = settings;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAppPreferences(AppPreferences prefs) async {
    _appPreferences = prefs;
    await _storage.saveAppPreferences(_appPreferences);
    notifyListeners();
  }

  Future<void> setDayData(DateTime date, DayEntry entry) async {
    final key = GoalCalculator.dateToKey(date);
    final hours = entry.hours.clamp(0.0, double.infinity).toDouble();
    final amount = entry.amount.clamp(0.0, double.infinity).toDouble();

    if (entry.isEmpty) {
      _dayData.remove(key);
    } else {
      _dayData[key] = entry.copyWith(hours: hours, amount: amount);
    }

    await _storage.saveDayData(_dayData);
    notifyListeners();
  }

  Future<void> clearDay(DateTime date) async {
    await setDayData(date, const DayEntry());
  }

  Future<void> addShiftToday({
    required double hours,
    required double amount,
    String notes = '',
    int? mood,
    int? energy,
  }) async {
    if (hours == 0 && amount == 0) return;

    final today = GoalCalculator.dateOnly(DateTime.now());
    final existing = calculator.getDayData(today);

    await setDayData(
      today,
      existing.copyWith(
        hours: existing.hours + hours,
        amount: existing.amount + amount,
        notes: notes.isNotEmpty ? notes : existing.notes,
        mood: mood ?? existing.mood,
        energy: energy ?? existing.energy,
      ),
    );
  }

  Future<void> clearAll() async {
    _dayData = {};
    await _storage.saveDayData(_dayData);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveDarkMode(_isDarkMode);
    notifyListeners();
  }
}
