import 'package:flutter/material.dart';

enum StreakType { shifts, plan }

class StreakInfo {
  const StreakInfo({
    required this.type,
    required this.current,
    required this.best,
    required this.label,
  });

  final StreakType type;
  final int current;
  final int best;
  final String label;
}

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.completed,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final double target;
  final double progress;
  final bool completed;
  final IconData icon;
  final Color color;

  double get percent =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
}

class GoalAnalogies {
  const GoalAnalogies({
    required this.remainingAmount,
    required this.estimatedShifts,
    required this.estimatedHours,
    required this.avgShiftAmount,
    required this.avgShiftHours,
    required this.avgRate,
    required this.hasData,
  });

  final double remainingAmount;
  final int estimatedShifts;
  final int estimatedHours;
  final double avgShiftAmount;
  final double avgShiftHours;
  final double avgRate;
  final bool hasData;

  String get shiftsLabel {
    if (!hasData) return '—';
    return '≈ $estimatedShifts ${_pluralShifts(estimatedShifts)}';
  }

  String get hoursLabel {
    if (!hasData) return '—';
    return '≈ $estimatedHours ч';
  }

  static String _pluralShifts(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'смен';
    if (mod10 == 1) return 'смена';
    if (mod10 >= 2 && mod10 <= 4) return 'смены';
    return 'смен';
  }
}

class BestDayInsight {
  const BestDayInsight({
    required this.weekday,
    required this.weekdayLabel,
    required this.averagePercent,
    required this.deltaFromMean,
    required this.sampleDays,
    required this.hasData,
  });

  final int weekday;
  final String weekdayLabel;
  final double averagePercent;
  final double deltaFromMean;
  final int sampleDays;
  final bool hasData;

  String get summary {
    if (!hasData) return 'Недостаточно данных по дням недели.';
    final sign = deltaFromMean >= 0 ? '+' : '';
    return 'По $weekdayLabel вы в среднем $sign${deltaFromMean.toStringAsFixed(0)}% к плану '
        '(${averagePercent.toStringAsFixed(0)}% выполнения, $sampleDays дн.)';
  }
}

class WhatIfResult {
  const WhatIfResult({
    required this.extraHoursPerDay,
    required this.extraRatePerHour,
    required this.projectedDate,
    required this.daysNeeded,
    required this.dailyIncome,
    required this.isAchievable,
    required this.message,
  });

  final double extraHoursPerDay;
  final double extraRatePerHour;
  final DateTime? projectedDate;
  final double daysNeeded;
  final double dailyIncome;
  final bool isAchievable;
  final String message;
}

class ForecastScenario {
  const ForecastScenario({
    required this.label,
    required this.subtitle,
    required this.dateLabel,
    required this.daysNeeded,
    required this.dailyIncome,
    required this.color,
  });

  final String label;
  final String subtitle;
  final String dateLabel;
  final double daysNeeded;
  final double dailyIncome;
  final Color color;
}

class ConfidenceForecast {
  const ConfidenceForecast({
    required this.scenarios,
    required this.hasData,
  });

  final List<ForecastScenario> scenarios;
  final bool hasData;
}

class PeriodMetricDelta {
  const PeriodMetricDelta({
    required this.label,
    required this.current,
    required this.previous,
    required this.delta,
    required this.deltaPercent,
    required this.positiveIsGood,
    required this.unit,
  });

  final String label;
  final double current;
  final double previous;
  final double delta;
  final double deltaPercent;
  final bool positiveIsGood;
  final String unit;

  bool get improved =>
      positiveIsGood ? delta > 0 : delta < 0;

  bool get declined =>
      positiveIsGood ? delta < 0 : delta > 0;
}

class PeriodComparison {
  const PeriodComparison({
    required this.currentLabel,
    required this.previousLabel,
    required this.metrics,
    required this.hasPreviousData,
  });

  final String currentLabel;
  final String previousLabel;
  final List<PeriodMetricDelta> metrics;
  final bool hasPreviousData;
}
