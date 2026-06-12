import 'package:flutter/foundation.dart';

import '../models/day_entry.dart';
import '../models/goal_settings.dart';
import '../services/goal_calculator.dart';
import '../services/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider(this._storage);

  final StorageService _storage;

  GoalSettings _settings = GoalSettings.defaults();
  Map<String, DayEntry> _dayData = {};
  bool _isDarkMode = false;
  bool _isLoading = true;

  GoalSettings get settings => _settings;
  Map<String, DayEntry> get dayData => Map.unmodifiable(_dayData);
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  GoalCalculator get calculator => GoalCalculator(
        settings: _settings,
        dayData: _dayData,
      );

  Future<void> init() async {
    try {
      _settings = await _storage.loadSettings();
      _dayData = await _storage.loadDayData();
      _isDarkMode = await _storage.loadDarkMode();
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

  Future<void> setDayData(DateTime date, DayEntry entry) async {
    final key = GoalCalculator.dateToKey(date);
    final hours = entry.hours.clamp(0.0, double.infinity).toDouble();
    final amount = entry.amount.clamp(0.0, double.infinity).toDouble();

    if (hours == 0 && amount == 0 && entry.notes.isEmpty) {
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
  }) async {
    if (hours == 0 && amount == 0) return;

    final today = GoalCalculator.dateOnly(DateTime.now());
    final existing = calculator.getDayData(today);

    await setDayData(
      today,
      DayEntry(
        hours: existing.hours + hours,
        amount: existing.amount + amount,
        notes: notes.isNotEmpty ? notes : existing.notes,
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
