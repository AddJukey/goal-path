import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';

class GoalAnalogiesCard extends StatelessWidget {
  const GoalAnalogiesCard({super.key, required this.analogies});

  final GoalAnalogies analogies;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberFormat = NumberFormat.decimalPattern('ru');

    if (analogies.remainingAmount <= 0) {
      return const SizedBox.shrink();
    }

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
          const Text(
            'До цели осталось…',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${numberFormat.format(analogies.remainingAmount.floor())}₽',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: 14),
          if (!analogies.hasData)
            Text(
              'Добавьте смены — покажем, сколько осталось в привычных единицах.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _AnalogyTile(
                    icon: Icons.work_outline,
                    label: 'Смены',
                    value: analogies.shiftsLabel,
                    detail:
                        '~${analogies.avgShiftAmount.toStringAsFixed(0)}₽/смена',
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AnalogyTile(
                    icon: Icons.schedule_outlined,
                    label: 'Часы',
                    value: analogies.hoursLabel,
                    detail:
                        '${analogies.avgRate.toStringAsFixed(0)} ₽/ч',
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalogyTile extends StatelessWidget {
  const _AnalogyTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            detail,
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
