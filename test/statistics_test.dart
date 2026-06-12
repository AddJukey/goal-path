import 'package:flutter_test/flutter_test.dart';
import 'package:goal_path/models/day_entry.dart';
import 'package:goal_path/models/goal_settings.dart';
import 'package:goal_path/models/period_stats.dart';
import 'package:goal_path/services/goal_calculator.dart';
import 'package:goal_path/services/statistics_service.dart';

void main() {
  test('monthly average percent reflects daily achievement', () {
    final settings = GoalSettings(
      title: 'Test',
      targetAmount: 30000,
      deadline: DateTime(2026, 6, 30),
      startDate: DateTime(2026, 6, 1),
    );

    final calculator = GoalCalculator(
      settings: settings,
      dayData: {
        '2026-06-10': const DayEntry(hours: 8, amount: 5000),
        '2026-06-11': const DayEntry(hours: 6, amount: 3000),
      },
    );

    final report = StatisticsService().report(calculator, StatsPeriod.month);

    expect(report.totalAmount, 8000);
    expect(report.activeDays, 2);
    expect(report.averagePercent, greaterThan(0));
    expect(report.points.length, greaterThan(0));
  });
}
