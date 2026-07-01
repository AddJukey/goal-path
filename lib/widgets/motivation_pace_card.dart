import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class MotivationPaceCard extends StatelessWidget {
  const MotivationPaceCard({super.key, required this.pace});

  final PaceMotivation pace;

  @override
  Widget build(BuildContext context) {
    return FbCard(
      title: 'Что будет, если…',
      subtitle: 'Дедлайн: ${pace.deadlineLabel}',
      icon: Icons.speed_rounded,
      iconColor: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: !pace.hasData
          ? Text(
              'Добавьте смены за последнюю неделю — покажем прогноз.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : Column(
              children: pace.scenarios
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PaceRow(scenario: s),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _PaceRow extends StatelessWidget {
  const _PaceRow({required this.scenario});

  final PaceScenario scenario;

  @override
  Widget build(BuildContext context) {
    final dark = AppDecorations.isDark(context);
    final isLate = scenario.dateLabel.contains('после дедлайна');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scenario.color.withValues(alpha: dark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scenario.color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: scenario.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (scenario.isBoost)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.north_east_rounded,
                          size: 14,
                          color: AppColors.mint,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        scenario.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 13,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  scenario.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                scenario.dateLabel,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: isLate ? AppColors.rose : scenario.color,
                ),
              ),
              if (scenario.dailyAmount > 0)
                Text(
                  '${scenario.dailyAmount.toStringAsFixed(0)}₽/д',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
