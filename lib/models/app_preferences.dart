class AppPreferences {
  const AppPreferences({
    this.smartCoachEnabled = true,
    this.offlineCoachOnly = false,
    this.scriptedMixPercent = 35,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
  });

  final bool smartCoachEnabled;
  final bool offlineCoachOnly;
  /// When AI is on, this % of responses use local scripted text instead.
  final int scriptedMixPercent;
  final int focusMinutes;
  final int breakMinutes;

  AppPreferences copyWith({
    bool? smartCoachEnabled,
    bool? offlineCoachOnly,
    int? scriptedMixPercent,
    int? focusMinutes,
    int? breakMinutes,
  }) {
    return AppPreferences(
      smartCoachEnabled: smartCoachEnabled ?? this.smartCoachEnabled,
      offlineCoachOnly: offlineCoachOnly ?? this.offlineCoachOnly,
      scriptedMixPercent: scriptedMixPercent ?? this.scriptedMixPercent,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'smartCoachEnabled': smartCoachEnabled,
        'offlineCoachOnly': offlineCoachOnly,
        'scriptedMixPercent': scriptedMixPercent,
        'focusMinutes': focusMinutes,
        'breakMinutes': breakMinutes,
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      smartCoachEnabled: json['smartCoachEnabled'] as bool? ?? true,
      offlineCoachOnly: json['offlineCoachOnly'] as bool? ?? false,
      scriptedMixPercent:
          (json['scriptedMixPercent'] as num?)?.toInt().clamp(0, 100) ?? 35,
      focusMinutes: (json['focusMinutes'] as num?)?.toInt() ?? 25,
      breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 5,
    );
  }
}
