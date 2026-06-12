import 'package:intl/intl.dart';

import '../models/period_stats.dart';
import 'goal_calculator.dart';

class StatisticsService {
  PeriodAchievementReport report(GoalCalculator calculator, StatsPeriod period) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    final (start, end) = _periodBounds(period, today, calculator);

    if (period == StatsPeriod.year) {
      return _yearlyReport(calculator, start, end);
    }

    final points = <DayAchievement>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      if (!cursor.isBefore(GoalCalculator.dateOnly(calculator.settings.startDate)) &&
          !cursor.isAfter(GoalCalculator.dateOnly(calculator.settings.deadline))) {
        points.add(_dayAchievement(calculator, cursor));
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return _buildReport(period, start, end, points, calculator);
  }

  (DateTime, DateTime) _periodBounds(
    StatsPeriod period,
    DateTime today,
    GoalCalculator calculator,
  ) {
    switch (period) {
      case StatsPeriod.week:
        return (today.subtract(const Duration(days: 6)), today);
      case StatsPeriod.month:
        final start = DateTime(today.year, today.month, 1);
        return (start, today);
      case StatsPeriod.year:
        final start = DateTime(today.year, 1, 1);
        return (start, today);
    }
  }

  PeriodAchievementReport _yearlyReport(
    GoalCalculator calculator,
    DateTime start,
    DateTime end,
  ) {
    final points = <DayAchievement>[];
    var month = DateTime(start.year, start.month, 1);

    while (!month.isAfter(end)) {
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final effectiveEnd = monthEnd.isAfter(end) ? end : monthEnd;

      var amount = 0.0;
      var hours = 0.0;
      var percentSum = 0.0;
      var dayCount = 0;

      var day = month;
      while (!day.isAfter(effectiveEnd)) {
        if (!day.isBefore(GoalCalculator.dateOnly(calculator.settings.startDate)) &&
            !day.isAfter(GoalCalculator.dateOnly(calculator.settings.deadline))) {
          final achievement = _dayAchievement(calculator, day);
          amount += achievement.amount;
          hours += achievement.hours;
          percentSum += achievement.achievementPercent;
          dayCount++;
        }
        day = day.add(const Duration(days: 1));
      }

      points.add(
        DayAchievement(
          date: month,
          amount: amount,
          hours: hours,
          dailyTarget: 0,
          achievementPercent: dayCount > 0 ? percentSum / dayCount : 0,
        ),
      );

      month = DateTime(month.year, month.month + 1, 1);
    }

    return _buildReport(StatsPeriod.year, start, end, points, calculator);
  }

  DayAchievement _dayAchievement(GoalCalculator calculator, DateTime date) {
    final data = calculator.getDayData(date);
    final dailyTarget = _dailyTargetForDate(calculator, date);
    final percent = dailyTarget > 0
        ? (data.amount / dailyTarget) * 100
        : (data.amount > 0 ? 100 : 0);

    return DayAchievement(
      date: date,
      amount: data.amount,
      hours: data.hours,
      dailyTarget: dailyTarget,
      achievementPercent: percent,
    );
  }

  double _dailyTargetForDate(GoalCalculator calculator, DateTime date) {
    final deadline = GoalCalculator.dateOnly(calculator.settings.deadline);
    if (date.isAfter(deadline)) return 0;

    final earnedBefore = _earnedBefore(calculator, date);
    final remaining = (calculator.settings.targetAmount - earnedBefore)
        .clamp(0, double.infinity);

    if (remaining <= 0) return 0;

    final daysLeft = deadline.difference(date).inDays + 1;
    if (daysLeft <= 0) return 0;

    return remaining / daysLeft;
  }

  double _earnedBefore(GoalCalculator calculator, DateTime date) {
    var total = 0.0;
    for (final entryDate in calculator.allDates) {
      if (!entryDate.isBefore(date)) break;
      total += calculator.getDayData(entryDate).amount;
    }
    return total;
  }

  PeriodAchievementReport _buildReport(
    StatsPeriod period,
    DateTime start,
    DateTime end,
    List<DayAchievement> points,
    GoalCalculator calculator,
  ) {
    final totalAmount =
        points.fold<double>(0, (sum, p) => sum + p.amount);
    final totalHours =
        points.fold<double>(0, (sum, p) => sum + p.hours);
    final activeDays = points.where((p) => p.amount > 0 || p.hours > 0).length;

    final averagePercent = points.isEmpty
        ? 0
        : points.fold<double>(0, (sum, p) => sum + p.achievementPercent) /
            points.length;

    final target = calculator.settings.targetAmount;
    final goalSharePercent =
        target > 0 ? (totalAmount / target) * 100 : 0;

    return PeriodAchievementReport(
      period: period,
      start: start,
      end: end,
      points: points,
      averagePercent: averagePercent,
      totalAmount: totalAmount,
      totalHours: totalHours,
      goalSharePercent: goalSharePercent,
      activeDays: activeDays,
    );
  }

  static String formatPeriodRange(PeriodAchievementReport report) {
    final fmt = DateFormat('d MMM yyyy', 'ru');
    if (report.period == StatsPeriod.year) {
      return report.start.year.toString();
    }
    return '${fmt.format(report.start)} — ${fmt.format(report.end)}';
  }

  static String pointLabel(DayAchievement point, StatsPeriod period) {
    if (period == StatsPeriod.year) {
      return DateFormat('MMM', 'ru').format(point.date);
    }
    return point.date.day.toString();
  }
}
