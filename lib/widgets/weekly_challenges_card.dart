import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class WeeklyChallengesCard extends StatefulWidget {
  const WeeklyChallengesCard({super.key, required this.challenges});

  final List<WeeklyChallenge> challenges;

  @override
  State<WeeklyChallengesCard> createState() => _WeeklyChallengesCardState();
}

class _WeeklyChallengesCardState extends State<WeeklyChallengesCard> {
  static const _visibleCount = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = widget.challenges.take(_visibleCount).toList();
    final hidden = widget.challenges.length > _visibleCount
        ? widget.challenges.skip(_visibleCount).toList()
        : <WeeklyChallenge>[];
    final completedHidden =
        hidden.where((c) => c.completed).length;

    return FbCard(
      title: 'Челленджи недели',
      subtitle: 'Выполняй задания — получай награды',
      icon: Icons.emoji_events_outlined,
      iconColor: AppColors.purple,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          ...visible.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChallengeRow(challenge: c),
            ),
          ),
          if (hidden.isNotEmpty && !_expanded)
            _ExpandButton(
              count: hidden.length,
              completedCount: completedHidden,
              onTap: () => setState(() => _expanded = true),
            ),
          if (_expanded) ...[
            ...hidden.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ChallengeRow(challenge: c),
              ),
            ),
            _CollapseButton(
              onTap: () => setState(() => _expanded = false),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({
    required this.count,
    required this.completedCount,
    required this.onTap,
  });

  final int count;
  final int completedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppDecorations.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
            color: AppColors.primary.withValues(alpha: dark ? 0.08 : 0.05),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Ещё $count ${_plural(count)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              if (completedCount > 0) ...[
                const SizedBox(width: 8),
                FbBadge(
                  label: '$completedCount ✓',
                  color: AppColors.mint,
                  small: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _plural(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'челленджей';
    if (mod10 == 1) return 'челлендж';
    if (mod10 >= 2 && mod10 <= 4) return 'челленджа';
    return 'челленджей';
  }
}

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.expand_less_rounded, size: 18),
      label: const Text('Свернуть'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
