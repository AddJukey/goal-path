import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'goal_calculator.dart';
import 'statistics_service.dart';

class MotivationService {
  final _stats = StatisticsService();

  StreakInfo shiftStreak(GoalCalculator calculator) {
    return _streak(
      calculator,
      type: StreakType.shifts,
      label: 'Смены подряд',
      qualifies: (date) {
        final data = calculator.getDayData(date);
        return data.hours > 0 || data.amount > 0;
      },
    );
  }

  StreakInfo planStreak(GoalCalculator calculator) {
    return _streak(
      calculator,
      type: StreakType.plan,
      label: 'План подряд',
      qualifies: (date) => _stats.isDailyPlanMet(calculator, date),
    );
  }

  StreakInfo _streak(
    GoalCalculator calculator, {
    required StreakType type,
    required String label,
    required bool Function(DateTime date) qualifies,
  }) {
    final start = GoalCalculator.dateOnly(calculator.settings.startDate);
    final today = GoalCalculator.dateOnly(DateTime.now());

    final current = _currentStreak(start, today, qualifies);
    final best = _bestStreak(start, today, qualifies);

    return StreakInfo(
      type: type,
      current: current,
      best: best,
      label: label,
    );
  }

  int _currentStreak(
    DateTime start,
    DateTime today,
    bool Function(DateTime date) qualifies,
  ) {
    var cursor = today;
    if (!qualifies(today)) {
      cursor = today.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (!cursor.isBefore(start)) {
      if (qualifies(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _bestStreak(
    DateTime start,
    DateTime today,
    bool Function(DateTime date) qualifies,
  ) {
    var best = 0;
    var current = 0;
    var cursor = start;

    while (!cursor.isAfter(today)) {
      if (qualifies(cursor)) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return best;
  }

  List<WeeklyChallenge> weeklyChallenges(GoalCalculator calculator) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekAmount = _sumAmount(calculator, weekStart, weekEnd);
    final weekActiveDays = _countActiveDays(calculator, weekStart, weekEnd);
    final currentShiftStreak = _streak(
      calculator,
      type: StreakType.shifts,
      label: 'Смены подряд',
      qualifies: (date) {
        final data = calculator.getDayData(date);
        return data.hours > 0 || data.amount > 0;
      },
    ).current;

    final remaining = calculator.remainingTarget;
    final weeksLeft =
        (calculator.remainingDays.length / 7).ceil().clamp(1, 999);
    final weeklyTarget = remaining > 0
        ? (remaining / weeksLeft).clamp(5000.0, double.infinity)
        : 10000.0;

    final last7 = calculator.last7DaysStats;
    final fallbackTarget = last7.amount > 0
        ? last7.amount * 1.1
        : weeklyTarget;

    final earnTarget = remaining > 0
        ? weeklyTarget.toDouble()
        : fallbackTarget.clamp(5000.0, double.infinity).toDouble();

    return [
      WeeklyChallenge(
        id: 'weekly_earn',
        title: 'Заработок недели',
        description:
            'Заработай ${earnTarget.toStringAsFixed(0)}₽ до ${DateFormat('d MMM', 'ru').format(weekEnd)}',
        target: earnTarget,
        progress: weekAmount,
        completed: weekAmount >= earnTarget,
        icon: Icons.payments_outlined,
        color: AppColors.mint,
      ),
      WeeklyChallenge(
        id: 'weekly_shifts',
        title: '5 смен подряд',
        description: 'Отмечай смены без пропусков',
        target: 5,
        progress: currentShiftStreak.toDouble(),
        completed: currentShiftStreak >= 5,
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFB923C),
      ),
      WeeklyChallenge(
        id: 'weekly_days',
        title: '5 рабочих дней',
        description: 'Активных дней на этой неделе',
        target: 5,
        progress: weekActiveDays.toDouble(),
        completed: weekActiveDays >= 5,
        icon: Icons.calendar_month_outlined,
        color: AppColors.purple,
      ),
    ];
  }

  GoalAnalogies goalAnalogies(GoalCalculator calculator) {
    final remaining = calculator.remainingTarget;
    final stats = calculator.totalStats;

    var activeDays = 0;
    var totalAmount = 0.0;
    var totalHours = 0.0;

    for (final entry in calculator.dayData.values) {
      if (entry.amount > 0 || entry.hours > 0) {
        activeDays++;
        totalAmount += entry.amount;
        totalHours += entry.hours;
      }
    }

    if (activeDays == 0 || remaining <= 0) {
      return GoalAnalogies(
        remainingAmount: remaining,
        estimatedShifts: 0,
        estimatedHours: 0,
        avgShiftAmount: 0,
        avgShiftHours: 0,
        avgRate: stats.avgRate,
        hasData: activeDays > 0 && remaining > 0,
      );
    }

    final avgShiftAmount = totalAmount / activeDays;
    final avgShiftHours = totalHours / activeDays;
    final avgRate = stats.avgRate > 0 ? stats.avgRate : 0.0;

    final shifts = avgShiftAmount > 0
        ? (remaining / avgShiftAmount).ceil()
        : 0;
    final hours = avgRate > 0 ? (remaining / avgRate).ceil() : 0;

    return GoalAnalogies(
      remainingAmount: remaining,
      estimatedShifts: shifts,
      estimatedHours: hours,
      avgShiftAmount: avgShiftAmount,
      avgShiftHours: avgShiftHours,
      avgRate: avgRate,
      hasData: true,
    );
  }

  double _sumAmount(
    GoalCalculator calculator,
    DateTime start,
    DateTime end,
  ) {
    var total = 0.0;
    var cursor = start;
    while (!cursor.isAfter(end)) {
      total += calculator.getDayData(cursor).amount;
      cursor = cursor.add(const Duration(days: 1));
    }
    return total;
  }

  int _countActiveDays(
    GoalCalculator calculator,
    DateTime start,
    DateTime end,
  ) {
    var count = 0;
    var cursor = start;
    while (!cursor.isAfter(end)) {
      final data = calculator.getDayData(cursor);
      if (data.amount > 0 || data.hours > 0) count++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return count;
  }
}
