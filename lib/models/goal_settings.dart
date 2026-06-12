class GoalSettings {
  const GoalSettings({
    this.title = 'Моя цель',
    this.targetAmount = 500000,
    required this.deadline,
    required this.startDate,
  });

  final String title;
  final double targetAmount;
  final DateTime deadline;
  final DateTime startDate;

  GoalSettings copyWith({
    String? title,
    double? targetAmount,
    DateTime? deadline,
    DateTime? startDate,
  }) {
    return GoalSettings(
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      deadline: deadline ?? this.deadline,
      startDate: startDate ?? this.startDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'targetAmount': targetAmount,
        'deadline': deadline.toIso8601String(),
        'startDate': startDate.toIso8601String(),
      };

  factory GoalSettings.fromJson(Map<String, dynamic> json) {
    return GoalSettings(
      title: json['title'] as String? ?? 'Моя цель',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 500000,
      deadline: DateTime.parse(json['deadline'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
    );
  }

  factory GoalSettings.defaults() {
    final now = DateTime.now();
    return GoalSettings(
      deadline: DateTime(now.year, 11, 30),
      startDate: DateTime(now.year, now.month, now.day),
    );
  }
}
