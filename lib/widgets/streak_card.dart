import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.shiftStreak,
    required this.planStreak,
  });

  final StreakInfo shiftStreak;
  final StreakInfo planStreak;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: const Color(0xFFFB923C),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Серии',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StreakTile(
                  label: shiftStreak.label,
                  current: shiftStreak.current,
                  best: shiftStreak.best,
                  color: const Color(0xFFFB923C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StreakTile(
                  label: planStreak.label,
                  current: planStreak.current,
                  best: planStreak.best,
                  color: AppColors.mint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({
    required this.label,
    required this.current,
    required this.best,
    required this.color,
  });

  final String label;
  final int current;
  final int best;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$current',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            'рекорд: $best',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
