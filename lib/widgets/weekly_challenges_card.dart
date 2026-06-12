import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';

class WeeklyChallengesCard extends StatelessWidget {
  const WeeklyChallengesCard({super.key, required this.challenges});

  final List<WeeklyChallenge> challenges;

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
          const Text(
            'Челленджи недели',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...challenges.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChallengeRow(challenge: c),
              )),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge});

  final WeeklyChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = challenge.percent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightBg,
        borderRadius: BorderRadius.circular(14),
        border: challenge.completed
            ? Border.all(color: challenge.color.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: challenge.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? AppColors.darkProgressBg
                        : AppColors.lightProgressBg,
                    valueColor:
                        AlwaysStoppedAnimation(challenge.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            challenge.completed
                ? '✓'
                : '${(percent * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: challenge.completed
                  ? challenge.color
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
