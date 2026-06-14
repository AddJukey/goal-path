import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class GoalAnalogiesCard extends StatelessWidget {
  const GoalAnalogiesCard({super.key, required this.analogies});

  final GoalAnalogies analogies;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('ru');

    if (analogies.remainingAmount <= 0) {
      return const SizedBox.shrink();
    }

    return FbCard(
      title: 'До цели осталось…',
      icon: Icons.flag_outlined,
      iconColor: AppColors.purple,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      trailing: Text(
        '${numberFormat.format(analogies.remainingAmount.floor())}₽',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.purple,
        ),
      ),
      child: !analogies.hasData
          ? FbAlert(
              message:
                  'Добавьте смены — покажем, сколько осталось в привычных единицах.',
              icon: Icons.lightbulb_outline,
              color: AppColors.mint,
            )
          : Row(
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
                    detail: '${analogies.avgRate.toStringAsFixed(0)} ₽/ч',
                    color: AppColors.primary,
                  ),
                ),
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
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
