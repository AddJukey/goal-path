import 'package:flutter/material.dart';

class MilestoneBadge {
  const MilestoneBadge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.threshold,
    required this.icon,
    required this.colors,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String subtitle;
  final double threshold;
  final IconData icon;
  final List<Color> colors;
  final bool unlocked;
}
