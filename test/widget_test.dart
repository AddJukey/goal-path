import 'package:flutter_test/flutter_test.dart';
import 'package:goal_path/services/goal_calculator.dart';
import 'package:goal_path/models/day_entry.dart';
import 'package:goal_path/models/goal_settings.dart';

void main() {
  test('remaining target decreases with earnings', () {
    final settings = GoalSettings(
      targetAmount: 100000,
      deadline: DateTime(2026, 12, 31),
      startDate: DateTime(2026, 1, 1),
    );

    final calculator = GoalCalculator(
      settings: settings,
      dayData: {
        '2026-06-01': const DayEntry(hours: 8, amount: 5000),
      },
    );

    expect(calculator.totalStats.totalAmount, 5000);
    expect(calculator.remainingTarget, 95000);
  });
}
