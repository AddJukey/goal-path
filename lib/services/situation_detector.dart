import '../models/coach_models.dart';
import '../models/day_entry.dart';
import '../services/goal_calculator.dart';
import '../services/motivation_service.dart';

class SituationDetector {
  final _motivation = MotivationService();

  CoachContext buildShiftSaved(GoalCalculator calculator, DayEntry entry) {
    final stats = calculator.totalStats;
    final progress = calculator.settings.targetAmount > 0
        ? stats.totalAmount / calculator.settings.targetAmount * 100
        : 0.0;
    final streak = _motivation.shiftStreak(calculator).current;
    final avgAmount = _avgShiftAmount(calculator);

    var situation = CoachSituation.shiftSaved;
    if (entry.mood != null && entry.mood! <= 2) {
      situation = CoachSituation.lowMood;
    } else if (entry.mood != null && entry.mood! >= 4) {
      situation = CoachSituation.highMood;
    } else if (entry.energy != null && entry.energy! <= 2) {
      situation = CoachSituation.lowEnergy;
    } else if (entry.amount > 0 && entry.amount >= avgAmount * 1.25) {
      situation = CoachSituation.bigShift;
    } else if (progress >= 80) {
      situation = CoachSituation.goalNear;
    }

    return CoachContext(
      situation: situation,
      goalTitle: calculator.settings.title,
      progressPercent: progress,
      remainingRub: calculator.remainingTarget,
      daysLeft: calculator.remainingDays.length,
      shiftAmount: entry.amount,
      shiftHours: entry.hours,
      shiftStreak: streak,
      mood: entry.mood,
      energy: entry.energy,
    );
  }

  CoachContext buildDailyTip(GoalCalculator calculator) {
    final streak = _motivation.shiftStreak(calculator);
    final stats = calculator.totalStats;
    final progress = calculator.settings.targetAmount > 0
        ? stats.totalAmount / calculator.settings.targetAmount * 100
        : 0.0;
    final daysLeft = calculator.remainingDays.length.clamp(1, 9999);
    final neededDaily = calculator.remainingTarget / daysLeft;
    final last7 = calculator.last7DaysStats;
    final currentDaily = last7.amount > 0 ? last7.amount / 7 : 0.0;
    final isBehind =
        currentDaily > 0 && neededDaily > 0 && currentDaily < neededDaily * 0.92;
    final isAhead = currentDaily > neededDaily * 1.08;

    CoachSituation situation;
    if (isBehind) {
      situation = CoachSituation.behindPace;
    } else if (isAhead) {
      situation = CoachSituation.aheadPace;
    } else if (streak.current == 0 && streak.best > 2) {
      situation = CoachSituation.streakBroken;
    } else if (progress >= 80) {
      situation = CoachSituation.goalNear;
    } else {
      situation = CoachSituation.dailyTip;
    }

    return CoachContext(
      situation: situation,
      goalTitle: calculator.settings.title,
      progressPercent: progress,
      remainingRub: calculator.remainingTarget,
      daysLeft: calculator.remainingDays.length,
      shiftStreak: streak.current,
    );
  }

  CoachContext buildMoodInsight(
    GoalCalculator calculator, {
    required double avgMoodHighEarn,
    required double avgMoodLowEarn,
    required int sampleDays,
  }) {
    String hint = '';
    if (sampleDays >= 5 && avgMoodHighEarn > avgMoodLowEarn * 1.08) {
      hint =
          'При настроении 4–5 вы в среднем зарабатываете на ${((avgMoodHighEarn / avgMoodLowEarn - 1) * 100).toStringAsFixed(0)}% больше';
    }

    return CoachContext(
      situation: CoachSituation.moodInsight,
      goalTitle: calculator.settings.title,
      moodEarningsHint: hint,
      avgMood: _avgMood(calculator),
      avgEnergy: _avgEnergy(calculator),
    );
  }

  double _avgShiftAmount(GoalCalculator calculator) {
    var total = 0.0;
    var count = 0;
    for (final date in calculator.allDates) {
      final d = calculator.getDayData(date);
      if (d.amount > 0) {
        total += d.amount;
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  double? _avgMood(GoalCalculator calculator) {
    var sum = 0.0;
    var n = 0;
    for (final date in calculator.allDates) {
      final m = calculator.getDayData(date).mood;
      if (m != null) {
        sum += m;
        n++;
      }
    }
    return n > 0 ? sum / n : null;
  }

  double? _avgEnergy(GoalCalculator calculator) {
    var sum = 0.0;
    var n = 0;
    for (final date in calculator.allDates) {
      final e = calculator.getDayData(date).energy;
      if (e != null) {
        sum += e;
        n++;
      }
    }
    return n > 0 ? sum / n : null;
  }
}
