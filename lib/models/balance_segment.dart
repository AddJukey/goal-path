import 'package:flutter/material.dart';

class BalanceSegment {
  const BalanceSegment({
    required this.label,
    required this.percent,
    required this.color,
    required this.detail,
  });

  final String label;
  final double percent;
  final Color color;
  final String detail;
}

class GoalBalance {
  const GoalBalance({
    required this.overallPercent,
    required this.segments,
  });

  final double overallPercent;
  final List<BalanceSegment> segments;
}
