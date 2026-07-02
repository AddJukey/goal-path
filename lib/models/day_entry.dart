class DayEntry {
  const DayEntry({
    this.hours = 0,
    this.amount = 0,
    this.notes = '',
    this.mood,
    this.energy,
  });

  final double hours;
  final double amount;
  final String notes;
  /// 1–5 or null if not set.
  final int? mood;
  /// 1–5 or null if not set.
  final int? energy;

  bool get isEmpty =>
      hours == 0 &&
      amount == 0 &&
      notes.isEmpty &&
      mood == null &&
      energy == null;

  double get hourlyRate => hours > 0 ? amount / hours : 0;

  DayEntry copyWith({
    double? hours,
    double? amount,
    String? notes,
    int? mood,
    int? energy,
    bool clearMood = false,
    bool clearEnergy = false,
  }) {
    return DayEntry(
      hours: hours ?? this.hours,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      mood: clearMood ? null : (mood ?? this.mood),
      energy: clearEnergy ? null : (energy ?? this.energy),
    );
  }

  Map<String, dynamic> toJson() => {
        'hours': hours,
        'amount': amount,
        'notes': notes,
        if (mood != null) 'mood': mood,
        if (energy != null) 'energy': energy,
      };

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      hours: (json['hours'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      mood: _parseLevel(json['mood']),
      energy: _parseLevel(json['energy']),
    );
  }

  static int? _parseLevel(dynamic value) {
    if (value == null) return null;
    final n = (value as num).toInt();
    if (n < 1 || n > 5) return null;
    return n;
  }
}
