import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'goal_calculator.dart';
import 'statistics_service.dart';

class InsightsService {
  final _stats = StatisticsService();

  BestDayInsight bestDayOfWeek(GoalCalculator calculator) {
    final weekdayPercents = <int, List<double>>{};

    for (final date in calculator.allDates) {
      if (date.isAfter(GoalCalculator.dateOnly(DateTime.now()))) continue;

      final data = calculator.getDayData(date);
      if (data.amount <= 0 && data.hours <= 0) continue;

      final achievement = _stats.dayAchievement(calculator, date);
      weekdayPercents
          .putIfAbsent(date.weekday, () => [])
          .add(achievement.achievementPercent);
    }

    if (weekdayPercents.isEmpty) {
      return const BestDayInsight(
        weekday: 0,
        weekdayLabel: '',
        averagePercent: 0,
        deltaFromMean: 0,
        sampleDays: 0,
        hasData: false,
      );
    }

    final weekdayAverages = <int, double>{};
    for (final entry in weekdayPercents.entries) {
      final avg = entry.value.fold<double>(0, (a, b) => a + b) /
          entry.value.length;
      weekdayAverages[entry.key] = avg;
    }

    var bestWeekday = weekdayAverages.keys.first;
    var bestAvg = weekdayAverages[bestWeekday]!;

    for (final entry in weekdayAverages.entries) {
      if (entry.value > bestAvg) {
        bestWeekday = entry.key;
        bestAvg = entry.value;
      }
    }

    final weekdayLabel = _weekdayLabel(bestWeekday, accusative: true);

    return BestDayInsight(
      weekday: bestWeekday,
      weekdayLabel: weekdayLabel,
      averagePercent: bestAvg,
      deltaFromMean: bestAvg - 100,
      sampleDays: weekdayPercents[bestWeekday]!.length,
      hasData: true,
    );
  }

  WhatIfResult simulate(
    GoalCalculator calculator, {
    required double extraHoursPerDay,
    required double extraRatePerHour,
  }) {
    final remaining = calculator.remainingTarget;
    if (remaining <= 0) {
      return WhatIfResult(
        extraHoursPerDay: extraHoursPerDay,
        extraRatePerHour: extraRatePerHour,
        projectedDate: null,
        daysNeeded: 0,
        dailyIncome: 0,
        isAchievable: true,
        message: 'Цель уже достигнута',
      );
    }

    final last7 = calculator.last7DaysStats;
    final baseHours = last7.hours > 0 ? last7.hours / 7 : 6.0;
    final baseRate = last7.avgRate > 0
        ? last7.avgRate
        : calculator.totalStats.avgRate;

    if (baseRate <= 0 && extraRatePerHour <= 0) {
      return WhatIfResult(
        extraHoursPerDay: extraHoursPerDay,
        extraRatePerHour: extraRatePerHour,
        projectedDate: null,
        daysNeeded: double.infinity,
        dailyIncome: 0,
        isAchievable: false,
        message: 'Добавьте смены, чтобы рассчитать прогноз',
      );
    }

    final dailyHours = baseHours + extraHoursPerDay;
    final effectiveRate = baseRate + extraRatePerHour;
    final dailyIncome = dailyHours * effectiveRate;

    if (dailyIncome <= 0) {
      return WhatIfResult(
        extraHoursPerDay: extraHoursPerDay,
        extraRatePerHour: extraRatePerHour,
        projectedDate: null,
        daysNeeded: double.infinity,
        dailyIncome: 0,
        isAchievable: false,
        message: 'Недостаточно данных для расчёта',
      );
    }

    final daysNeeded = remaining / dailyIncome;
    final deadlineDays = calculator.remainingDays.length;

    DateTime? projectedDate;
    String message;

    if (daysNeeded > deadlineDays) {
      projectedDate = null;
      message = 'После дедлайна (+${(daysNeeded - deadlineDays).ceil()} дн.)';
    } else {
      projectedDate =
          DateTime.now().add(Duration(days: daysNeeded.ceil()));
      message = DateFormat('d MMMM yyyy', 'ru').format(projectedDate);
    }

    return WhatIfResult(
      extraHoursPerDay: extraHoursPerDay,
      extraRatePerHour: extraRatePerHour,
      projectedDate: projectedDate,
      daysNeeded: daysNeeded,
      dailyIncome: dailyIncome,
      isAchievable: daysNeeded <= deadlineDays,
      message: message,
    );
  }

  ConfidenceForecast confidenceForecast(GoalCalculator calculator) {
    final remaining = calculator.remainingTarget;
    if (remaining <= 0) {
      return ConfidenceForecast(
        hasData: true,
        scenarios: [
          ForecastScenario(
            label: 'Как сейчас',
            subtitle: 'Текущий темп',
            dateLabel: '✅ достигнута',
            daysNeeded: 0,
            dailyIncome: 0,
            color: AppColors.mint,
          ),
        ],
      );
    }

    final currentPace = _currentPace(calculator);
    final monthlyRates = _monthlyEarningRates(calculator);

    if (currentPace.dailyIncome <= 0 && monthlyRates.isEmpty) {
      return const ConfidenceForecast(scenarios: [], hasData: false);
    }

    final bestMonth = monthlyRates.isEmpty
        ? currentPace.dailyIncome
        : monthlyRates.reduce((a, b) => a > b ? a : b) / 30;
    final worstMonth = monthlyRates.isEmpty
        ? currentPace.dailyIncome * 0.7
        : monthlyRates.reduce((a, b) => a < b ? a : b) / 30;

    final deadlineDays = calculator.remainingDays.length;

    return ConfidenceForecast(
      hasData: true,
      scenarios: [
        _scenario(
          label: 'Как сейчас',
          subtitle: '${currentPace.hoursPerDay.toStringAsFixed(1)} ч/день, '
              '${currentPace.rate.toStringAsFixed(0)} ₽/ч',
          dailyIncome: currentPace.dailyIncome,
          remaining: remaining,
          deadlineDays: deadlineDays,
          color: AppColors.blue,
        ),
        _scenario(
          label: 'Лучший месяц',
          subtitle: 'Ваш максимальный темп',
          dailyIncome: bestMonth,
          remaining: remaining,
          deadlineDays: deadlineDays,
          color: AppColors.mint,
        ),
        _scenario(
          label: 'Худший месяц',
          subtitle: 'Консервативный сценарий',
          dailyIncome: worstMonth > 0 ? worstMonth : currentPace.dailyIncome * 0.5,
          remaining: remaining,
          deadlineDays: deadlineDays,
          color: AppColors.purple,
        ),
      ],
    );
  }

  ({double hoursPerDay, double rate, double dailyIncome}) _currentPace(
    GoalCalculator calculator,
  ) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 29));
    var hours = 0.0;
    var amount = 0.0;
    var activeDays = 0;

    var cursor = start;
    while (!cursor.isAfter(today)) {
      if (cursor.isBefore(
          GoalCalculator.dateOnly(calculator.settings.startDate))) {
        cursor = cursor.add(const Duration(days: 1));
        continue;
      }
      final data = calculator.getDayData(cursor);
      if (data.hours > 0 || data.amount > 0) {
        hours += data.hours;
        amount += data.amount;
        activeDays++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    if (activeDays == 0) {
      final last7 = calculator.last7DaysStats;
      final hpd = last7.hours / 7;
      return (
        hoursPerDay: hpd,
        rate: last7.avgRate,
        dailyIncome: hpd * last7.avgRate,
      );
    }

    final hpd = hours / activeDays;
    final rate = hours > 0 ? amount / hours : 0.0;
    return (hoursPerDay: hpd, rate: rate, dailyIncome: hpd * rate);
  }

  List<double> _monthlyEarningRates(GoalCalculator calculator) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    final amounts = <double>[];

    for (var i = 0; i < 6; i++) {
      final month = DateTime(today.year, today.month - i, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final effectiveEnd = monthEnd.isAfter(today) ? today : monthEnd;

      var amount = 0.0;
      var cursor = month;
      while (!cursor.isAfter(effectiveEnd)) {
        if (!cursor.isBefore(
            GoalCalculator.dateOnly(calculator.settings.startDate))) {
          amount += calculator.getDayData(cursor).amount;
        }
        cursor = cursor.add(const Duration(days: 1));
      }
      if (amount > 0) amounts.add(amount);
    }
    return amounts;
  }

  ForecastScenario _scenario({
    required String label,
    required String subtitle,
    required double dailyIncome,
    required double remaining,
    required int deadlineDays,
    required Color color,
  }) {
    if (dailyIncome <= 0) {
      return ForecastScenario(
        label: label,
        subtitle: subtitle,
        dateLabel: 'нет данных',
        daysNeeded: double.infinity,
        dailyIncome: 0,
        color: color,
      );
    }

    final daysNeeded = remaining / dailyIncome;
    String dateLabel;
    if (daysNeeded > deadlineDays) {
      dateLabel = '➜ после дедлайна';
    } else {
      final date = DateTime.now().add(Duration(days: daysNeeded.ceil()));
      dateLabel = DateFormat('dd.MM.yyyy').format(date);
    }

    return ForecastScenario(
      label: label,
      subtitle: subtitle,
      dateLabel: dateLabel,
      daysNeeded: daysNeeded,
      dailyIncome: dailyIncome,
      color: color,
    );
  }

  PeriodComparison monthComparison(GoalCalculator calculator) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    final thisStart = DateTime(today.year, today.month, 1);
    final lastMonthEnd = thisStart.subtract(const Duration(days: 1));
    final lastStart = DateTime(lastMonthEnd.year, lastMonthEnd.month, 1);

    final current = _periodMetrics(calculator, thisStart, today);
    final previous = _periodMetrics(calculator, lastStart, lastMonthEnd);

    final fmt = DateFormat('LLLL', 'ru');

    return PeriodComparison(
      currentLabel: fmt.format(thisStart),
      previousLabel: fmt.format(lastStart),
      hasPreviousData: previous.activeDays > 0,
      metrics: [
        _metricDelta(
          label: 'Заработок',
          current: current.amount,
          previous: previous.amount,
          positiveIsGood: true,
          unit: '₽',
        ),
        _metricDelta(
          label: 'Часы',
          current: current.hours,
          previous: previous.hours,
          positiveIsGood: true,
          unit: 'ч',
        ),
        _metricDelta(
          label: 'Ставка',
          current: current.avgRate,
          previous: previous.avgRate,
          positiveIsGood: true,
          unit: '₽/ч',
        ),
        _metricDelta(
          label: 'Активных дней',
          current: current.activeDays.toDouble(),
          previous: previous.activeDays.toDouble(),
          positiveIsGood: true,
          unit: 'дн',
        ),
      ],
    );
  }

  ({double amount, double hours, double avgRate, int activeDays})
      _periodMetrics(
    GoalCalculator calculator,
    DateTime start,
    DateTime end,
  ) {
    var amount = 0.0;
    var hours = 0.0;
    var activeDays = 0;
    var cursor = start;

    while (!cursor.isAfter(end)) {
      if (!cursor.isBefore(
          GoalCalculator.dateOnly(calculator.settings.startDate))) {
        final data = calculator.getDayData(cursor);
        if (data.amount > 0 || data.hours > 0) {
          amount += data.amount;
          hours += data.hours;
          activeDays++;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return (
      amount: amount,
      hours: hours,
      avgRate: hours > 0 ? amount / hours : 0.0,
      activeDays: activeDays,
    );
  }

  PeriodMetricDelta _metricDelta({
    required String label,
    required double current,
    required double previous,
    required bool positiveIsGood,
    required String unit,
  }) {
    final delta = current - previous;
    final deltaPercent = previous != 0 ? (delta / previous) * 100 : 0.0;

    return PeriodMetricDelta(
      label: label,
      current: current,
      previous: previous,
      delta: delta,
      deltaPercent: deltaPercent,
      positiveIsGood: positiveIsGood,
      unit: unit,
    );
  }

  String _weekdayLabel(int weekday, {bool accusative = false}) {
    const nominative = [
      '',
      'понедельник',
      'вторник',
      'среда',
      'четверг',
      'пятница',
      'суббота',
      'воскресенье',
    ];
    const accusativeForms = [
      '',
      'понедельникам',
      'вторникам',
      'средам',
      'четвергам',
      'пятницам',
      'субботам',
      'воскресеньям',
    ];
    if (weekday < 1 || weekday > 7) return '';
    return accusative ? accusativeForms[weekday] : nominative[weekday];
  }
}
