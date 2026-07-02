enum CoachSituation {
  shiftSaved,
  behindPace,
  aheadPace,
  streakBroken,
  bigShift,
  goalNear,
  lowMood,
  highMood,
  lowEnergy,
  dailyTip,
  moodInsight,
}

enum CoachMessageKind { quote, advice, moodInsight }

class CoachContext {
  const CoachContext({
    required this.situation,
    this.goalTitle = '',
    this.progressPercent = 0,
    this.remainingRub = 0,
    this.daysLeft = 0,
    this.shiftAmount = 0,
    this.shiftHours = 0,
    this.shiftStreak = 0,
    this.mood,
    this.energy,
    this.avgMood,
    this.avgEnergy,
    this.moodEarningsHint = '',
  });

  final CoachSituation situation;
  final String goalTitle;
  final double progressPercent;
  final double remainingRub;
  final int daysLeft;
  final double shiftAmount;
  final double shiftHours;
  final int shiftStreak;
  final int? mood;
  final int? energy;
  final double? avgMood;
  final double? avgEnergy;
  final String moodEarningsHint;

  Map<String, dynamic> toJson() => {
        'situation': situation.name,
        'goalTitle': goalTitle,
        'progressPercent': progressPercent.round(),
        'remainingRub': remainingRub.round(),
        'daysLeft': daysLeft,
        'shiftAmount': shiftAmount.round(),
        'shiftHours': shiftHours,
        'shiftStreak': shiftStreak,
        if (mood != null) 'mood': mood,
        if (energy != null) 'energy': energy,
        if (avgMood != null) 'avgMood': avgMood!.toStringAsFixed(1),
        if (avgEnergy != null) 'avgEnergy': avgEnergy!.toStringAsFixed(1),
        if (moodEarningsHint.isNotEmpty) 'moodEarningsHint': moodEarningsHint,
      };
}

class CoachMessage {
  const CoachMessage({
    required this.text,
    required this.kind,
    required this.source,
    this.situation,
  });

  final String text;
  final CoachMessageKind kind;
  final CoachMessageSource source;
  final CoachSituation? situation;

  bool get isAi => source == CoachMessageSource.ai;
}

enum CoachMessageSource { scripted, ai }
