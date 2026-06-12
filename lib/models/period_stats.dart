enum StatsPeriod { week, month, year }

class DayAchievement {
  const DayAchievement({
    required this.date,
    required this.amount,
    required this.hours,
    required this.dailyTarget,
    required this.achievementPercent,
  });

  final DateTime date;
  final double amount;
  final double hours;
  final double dailyTarget;
  final double achievementPercent;
}

class PeriodAchievementReport {
  const PeriodAchievementReport({
    required this.period,
    required this.start,
    required this.end,
    required this.points,
    required this.averagePercent,
    required this.totalAmount,
    required this.totalHours,
    required this.goalSharePercent,
    required this.activeDays,
  });

  final StatsPeriod period;
  final DateTime start;
  final DateTime end;
  final List<DayAchievement> points;
  final double averagePercent;
  final double totalAmount;
  final double totalHours;
  final double goalSharePercent;
  final int activeDays;
}
