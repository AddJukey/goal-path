import 'package:flutter/material.dart';

import '../models/milestone_badge.dart';
import '../theme/app_theme.dart';
import 'goal_calculator.dart';
import 'motivation_service.dart';

class BadgeService {
  List<MilestoneBadge> badges(GoalCalculator calculator) {
    final earned = calculator.totalStats.totalAmount;
    final hours = calculator.totalStats.totalHours;
    final motivation = MotivationService();
    final shiftStreakBest = motivation.shiftStreak(calculator).best;

    return [
      _badge(
        id: 'first_shift',
        title: 'Старт',
        subtitle: 'Первая смена',
        threshold: 1,
        icon: Icons.rocket_launch_rounded,
        colors: [AppColors.blue, AppColors.mint],
        value: earned,
      ),
      _badge(
        id: '10k',
        title: '10k',
        subtitle: 'Первые 10 000₽',
        threshold: 10000,
        icon: Icons.star_rounded,
        colors: [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
        value: earned,
      ),
      _badge(
        id: '50k',
        title: '50k',
        subtitle: 'Полпути к 50k',
        threshold: 50000,
        icon: Icons.emoji_events_rounded,
        colors: [AppColors.purple, AppColors.blue],
        value: earned,
      ),
      _badge(
        id: '100k',
        title: '100k',
        subtitle: 'Сотня тысяч',
        threshold: 100000,
        icon: Icons.military_tech_rounded,
        colors: [const Color(0xFFF472B6), AppColors.purple],
        value: earned,
      ),
      _badge(
        id: 'hours_50',
        title: '50 ч',
        subtitle: '50 часов работы',
        threshold: 50,
        icon: Icons.schedule_rounded,
        colors: [AppColors.mintDark, AppColors.blue],
        value: hours,
      ),
      _badge(
        id: 'streak_7',
        title: '7 дней',
        subtitle: 'Серия из 7 смен',
        threshold: 7,
        icon: Icons.local_fire_department_rounded,
        colors: [const Color(0xFFFB923C), const Color(0xFFEF4444)],
        value: shiftStreakBest.toDouble(),
      ),
      _badge(
        id: 'goal_done',
        title: 'Цель!',
        subtitle: 'Цель достигнута',
        threshold: calculator.settings.targetAmount,
        icon: Icons.flag_rounded,
        colors: [AppColors.mint, const Color(0xFF34D399)],
        value: earned,
      ),
    ];
  }

  MilestoneBadge _badge({
    required String id,
    required String title,
    required String subtitle,
    required double threshold,
    required IconData icon,
    required List<Color> colors,
    required double value,
  }) {
    return MilestoneBadge(
      id: id,
      title: title,
      subtitle: subtitle,
      threshold: threshold,
      icon: icon,
      colors: colors,
      unlocked: value >= threshold,
    );
  }
}
