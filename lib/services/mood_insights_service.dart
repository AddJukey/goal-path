import '../services/goal_calculator.dart';

class MoodInsightsService {
  MoodCorrelation analyze(GoalCalculator calculator) {
    final highMood = <double>[];
    final lowMood = <double>[];
    var moodDays = 0;
    var energyDays = 0;
    var energySum = 0.0;

    for (final date in calculator.allDates) {
      if (date.isAfter(GoalCalculator.dateOnly(DateTime.now()))) continue;
      final entry = calculator.getDayData(date);
      if (entry.mood != null) {
        moodDays++;
        if (entry.amount > 0) {
          if (entry.mood! >= 4) {
            highMood.add(entry.amount);
          } else if (entry.mood! <= 2) {
            lowMood.add(entry.amount);
          }
        }
      }
      if (entry.energy != null) {
        energyDays++;
        energySum += entry.energy!;
      }
    }

    double avg(List<double> v) =>
        v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

    return MoodCorrelation(
      moodSampleDays: moodDays,
      energySampleDays: energyDays,
      avgEnergy: energyDays > 0 ? energySum / energyDays : null,
      avgHighMoodEarn: avg(highMood),
      avgLowMoodEarn: avg(lowMood),
      hasEarningsPattern: highMood.isNotEmpty &&
          lowMood.isNotEmpty &&
          avg(highMood) > avg(lowMood) * 1.05,
    );
  }
}

class MoodCorrelation {
  const MoodCorrelation({
    required this.moodSampleDays,
    required this.energySampleDays,
    required this.avgHighMoodEarn,
    required this.avgLowMoodEarn,
    required this.hasEarningsPattern,
    this.avgEnergy,
  });

  final int moodSampleDays;
  final int energySampleDays;
  final double? avgEnergy;
  final double avgHighMoodEarn;
  final double avgLowMoodEarn;
  final bool hasEarningsPattern;

  bool get hasData => moodSampleDays >= 3;
}
