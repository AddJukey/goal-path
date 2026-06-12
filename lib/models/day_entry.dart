class DayEntry {
  const DayEntry({
    this.hours = 0,
    this.amount = 0,
    this.notes = '',
  });

  final double hours;
  final double amount;
  final String notes;

  bool get isEmpty => hours == 0 && amount == 0 && notes.isEmpty;

  double get hourlyRate => hours > 0 ? amount / hours : 0;

  DayEntry copyWith({
    double? hours,
    double? amount,
    String? notes,
  }) {
    return DayEntry(
      hours: hours ?? this.hours,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'hours': hours,
        'amount': amount,
        'notes': notes,
      };

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      hours: (json['hours'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}
