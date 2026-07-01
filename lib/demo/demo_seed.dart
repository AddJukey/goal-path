import '../models/day_entry.dart';
import '../models/goal_settings.dart';
import '../services/goal_calculator.dart';

/// Sample data for store screenshots and web preview.
class DemoSeed {
  static GoalSettings settings() {
    final now = DateTime.now();
    return GoalSettings(
      title: 'MacBook Pro',
      targetAmount: 260000,
      startDate: DateTime(now.year, now.month - 2, 1),
      deadline: DateTime(now.year, 11, 30, 23, 59, 59),
    );
  }

  static Map<String, DayEntry> dayData() {
    final now = GoalCalculator.dateOnly(DateTime.now());
    final data = <String, DayEntry>{};

    void add(int daysAgo, double hours, double amount, [String notes = '']) {
      final date = now.subtract(Duration(days: daysAgo));
      data[GoalCalculator.dateToKey(date)] = DayEntry(
        hours: hours,
        amount: amount,
        notes: notes,
      );
    }

    add(0, 6, 3500, 'Хорошая смена');
    add(1, 5.5, 3200);
    add(2, 0, 0);
    add(3, 7, 4100);
    add(4, 6, 3600);
    add(5, 4, 2400);
    add(6, 8, 4800, 'Много заказов');
    add(7, 6, 3500);
    add(8, 5, 2900);
    add(9, 0, 0);
    add(10, 6.5, 3800);
    add(11, 7, 4200);
    add(12, 5, 3000);
    add(13, 6, 3400);
    add(14, 8, 4600);

    for (var i = 15; i <= 40; i += 2) {
      add(i, 5 + (i % 3), 2500 + (i * 40.0));
    }

    return data;
  }
}
