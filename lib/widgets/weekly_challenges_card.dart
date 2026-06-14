import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class WeeklyChallengesCard extends StatelessWidget {
  const WeeklyChallengesCard({super.key, required this.challenges});

  final List<WeeklyChallenge> challenges;

  @override
  Widget build(BuildContext context) {
    return FbCard(
      title: 'Челленджи недели',
      subtitle: 'Выполняй задания — получай награды',
      icon: Icons.emoji_events_outlined,
      iconColor: AppColors.purple,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: challenges
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ChallengeRow(challenge: c),
                ))
            .toList(),
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge});

  final WeeklyChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final dark = AppDecorations.isDark(context);
    final percent = challenge.percent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCardElevated : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(8),
        border: challenge.completed
            ? Border.all(color: challenge.color.withValues(alpha: 0.5))
            : Border.all(
                color: dark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: challenge.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              challenge.completed ? Icons.check_rounded : challenge.icon,
              color: challenge.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: dark
                        ? AppColors.darkProgressBg
                        : AppColors.lightProgressBg,
                    valueColor: AlwaysStoppedAnimation(challenge.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FbBadge(
            label: challenge.completed
                ? '✓'
                : '${(percent * 100).toStringAsFixed(0)}%',
            color: challenge.completed
                ? challenge.color
                : AppColors.lightTextSecondary,
            small: true,
          ),
        ],
      ),
    );
  }
}
