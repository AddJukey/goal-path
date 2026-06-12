import 'package:intl/intl.dart';

import '../models/day_entry.dart';
import '../models/goal_settings.dart';

class TotalStats {
  const TotalStats({
    required this.totalHours,
    required this.totalAmount,
    required this.avgRate,
  });

  final double totalHours;
  final double totalAmount;
  final double avgRate;
}

class PeriodStats {
  const PeriodStats({
    required this.hours,
    required this.amount,
    required this.avgRate,
  });

  final double hours;
  final double amount;
  final double avgRate;
}

class GoalCalculator {
  GoalCalculator({
    required this.settings,
    required this.dayData,
  });

  final GoalSettings settings;
  final Map<String, DayEntry> dayData;

  static String dateToKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<DateTime> get allDates {
    final dates = <DateTime>[];
    var current = dateOnly(settings.startDate);
    final end = dateOnly(settings.deadline);
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  DayEntry getDayData(DateTime date) {
    return dayData[dateToKey(date)] ?? const DayEntry();
  }

  TotalStats get totalStats {
    var totalHours = 0.0;
    var totalAmount = 0.0;
    for (final entry in dayData.values) {
      totalHours += entry.hours;
      totalAmount += entry.amount;
    }
    return TotalStats(
      totalHours: totalHours,
      totalAmount: totalAmount,
      avgRate: totalHours > 0 ? totalAmount / totalHours : 0,
    );
  }

  double get remainingTarget {
    final total = totalStats.totalAmount;
    return (settings.targetAmount - total)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  PeriodStats get last7DaysStats {
    final today = dateOnly(DateTime.now());
    var hours = 0.0;
    var amount = 0.0;

    for (var i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      if (day.isBefore(dateOnly(settings.startDate)) ||
          day.isAfter(dateOnly(settings.deadline))) {
        continue;
      }
      final data = getDayData(day);
      hours += data.hours;
      amount += data.amount;
    }

    return PeriodStats(
      hours: hours,
      amount: amount,
      avgRate: hours > 0 ? amount / hours : 0,
    );
  }

  List<DateTime> get remainingDays {
    final today = dateOnly(DateTime.now());
    return allDates.where((d) => !d.isBefore(today)).toList();
  }

  String forecastByDailyHours(double dailyHours, double effectiveRate) {
    final remaining = remainingTarget;
    if (remaining <= 0) return '✅ достигнута';
    if (dailyHours <= 0 || effectiveRate <= 0) return '∞';

    final daysLeft = remainingDays.length;
    final dailyIncome = dailyHours * effectiveRate;
    final daysNeeded = remaining / dailyIncome;

    if (daysNeeded > daysLeft) return '➜ после дедлайна';

    final date = DateTime.now().add(Duration(days: daysNeeded.ceil()));
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String get forecastOptimist {
    final rate = last7DaysStats.avgRate;
    if (rate == 0) return 'нет ставки';
    return forecastByDailyHours(12, rate);
  }

  String get forecastPessimist {
    final last7 = last7DaysStats;
    final rate = last7.avgRate;
    if (rate == 0) return 'недостаточно данных';

    final avgHours = last7.hours / 7;
    if (avgHours == 0) return 'нет данных';
    return forecastByDailyHours(avgHours, rate);
  }

  List<int> get milestones {
    final list = <int>[];
    for (var i = 50000; i <= settings.targetAmount; i += 50000) {
      list.add(i);
    }
    if (list.isEmpty || list.last < settings.targetAmount.toInt()) {
      list.add(settings.targetAmount.toInt());
    }
    return list;
  }

  String generateAdvice() {
    final total = totalStats.totalAmount;
    final remaining = remainingTarget;
    final avgRate = totalStats.avgRate;
    final last7 = last7DaysStats;

    if (remaining <= 0) return '🎉 Цель достигнута! Поздравляем!';
    if (last7.hours == 0) {
      return 'Внеси данные за последние дни, чтобы получить прогноз.';
    }
    if (avgRate < 350) {
      return '💰 Твоя средняя ставка ${avgRate.toStringAsFixed(0)} ₽/ч. '
          'Попробуй повысить эффективность.';
    }
    if (last7.hours / 7 < 6) {
      return '⏱️ В последнюю неделю ты работал в среднем '
          '${(last7.hours / 7).toStringAsFixed(1)} ч/день. '
          'Добавь 1–2 часа — и достигнешь цели быстрее.';
    }

    final nextMilestone = ((total / 50000).ceil() * 50000).toInt();
    final toNext = nextMilestone - total;
    if (toNext > 0 && toNext < 20000 && avgRate > 0) {
      return '🎯 До следующей вехи (${nextMilestone ~/ 1000}k) осталось '
          '${toNext.toStringAsFixed(0)}₽. '
          'Это примерно ${(toNext / avgRate).ceil()} часов.';
    }

    return '🔥 Ты в хорошем темпе! Продолжай в том же духе.';
  }

  Duration? get timeUntilDeadline {
    final now = DateTime.now();
    if (!settings.deadline.isAfter(now)) return null;
    return settings.deadline.difference(now);
  }

  String formatDeadlineCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return '$days дн $hours ч';
  }

  String buildCsv() {
    final buffer = StringBuffer('Дата,Часы,Сумма,Средняя за час,Заметки\n');
    for (final date in allDates) {
      final data = getDayData(date);
      if (!data.isEmpty) {
        final avg = data.hours > 0 ? data.hourlyRate.toStringAsFixed(2) : '0';
        final notes = data.notes.contains(',')
            ? '"${data.notes.replaceAll('"', '""')}"'
            : data.notes;
        buffer.writeln(
          '${dateToKey(date)},${data.hours},${data.amount},$avg,$notes',
        );
      }
    }
    return buffer.toString();
  }
}
