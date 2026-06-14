import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

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
    return FbCard(
      title: 'Серии',
      icon: Icons.local_fire_department_rounded,
      iconColor: AppColors.october,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _StreakTile(
              label: shiftStreak.label,
              current: shiftStreak.current,
              best: shiftStreak.best,
              color: AppColors.october,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            '$current',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'рекорд: $best',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
