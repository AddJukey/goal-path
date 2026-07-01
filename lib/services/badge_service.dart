import 'package:flutter/material.dart';

import '../models/milestone_badge.dart';
import '../theme/app_theme.dart';
import 'goal_calculator.dart';
import 'motivation_service.dart';

class BadgeService {
  List<MilestoneBadge> badges(GoalCalculator calculator) {
    final earned = calculator.totalStats.totalAmount;
    final hours = calculator.totalStats.totalHours;
    final rate = calculator.totalStats.avgRate;
    final motivation = MotivationService();

    final shiftStreakBest = motivation.shiftStreak(calculator).best;

    var activeDays = 0;
    for (final entry in calculator.dayData.values) {
      if (entry.amount > 0 || entry.hours > 0) activeDays++;
    }

    final target = calculator.settings.targetAmount;

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
        id: '5k',
        title: '5k',
        subtitle: 'Первые 5 000₽',
        threshold: 5000,
        icon: Icons.spa_rounded,
        colors: [AppColors.mintLight, AppColors.mint],
        value: earned,
      ),
      _badge(
        id: '10k',
        title: '10k',
        subtitle: '10 000₽ на счету',
        threshold: 10000,
        icon: Icons.star_rounded,
        colors: [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
        value: earned,
      ),
      _badge(
        id: '25k',
        title: '25k',
        subtitle: 'Четверть сотни',
        threshold: 25000,
        icon: Icons.diamond_outlined,
        colors: [AppColors.blue, AppColors.primary],
        value: earned,
      ),
      _badge(
        id: '50k',
        title: '50k',
        subtitle: 'Полсотни тысяч',
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
        id: 'hours_25',
        title: '25 ч',
        subtitle: '25 часов работы',
        threshold: 25,
        icon: Icons.timer_outlined,
        colors: [AppColors.primaryLight, AppColors.primary],
        value: hours,
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
        id: 'hours_100',
        title: '100 ч',
        subtitle: 'Сотня часов',
        threshold: 100,
        icon: Icons.hourglass_top_rounded,
        colors: [AppColors.october, const Color(0xFFEF4444)],
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
        id: 'streak_14',
        title: '14 дней',
        subtitle: 'Две недели подряд',
        threshold: 14,
        icon: Icons.bolt_rounded,
        colors: [const Color(0xFFF43F5E), AppColors.purple],
        value: shiftStreakBest.toDouble(),
      ),
      _badge(
        id: 'active_10',
        title: '10 дн',
        subtitle: '10 рабочих дней',
        threshold: 10,
        icon: Icons.calendar_today_rounded,
        colors: [AppColors.mint, AppColors.primary],
        value: activeDays.toDouble(),
      ),
      _badge(
        id: 'active_30',
        title: '30 дн',
        subtitle: '30 рабочих дней',
        threshold: 30,
        icon: Icons.event_available_rounded,
        colors: [AppColors.purple, AppColors.mint],
        value: activeDays.toDouble(),
      ),
      _badge(
        id: 'rate_500',
        title: '500₽/ч',
        subtitle: 'Ставка от 500₽/ч',
        threshold: 500,
        icon: Icons.trending_up_rounded,
        colors: [AppColors.primary, AppColors.mint],
        value: rate,
      ),
      _badge(
        id: 'goal_done',
        title: 'Цель!',
        subtitle: 'Цель достигнута',
        threshold: target,
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
