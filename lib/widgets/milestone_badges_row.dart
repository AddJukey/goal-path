import 'package:flutter/material.dart';

import '../models/milestone_badge.dart';
import '../theme/app_theme.dart';

class MilestoneBadgesRow extends StatelessWidget {
  const MilestoneBadgesRow({
    super.key,
    required this.badges,
  });

  final List<MilestoneBadge> badges;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = badges.where((b) => b.unlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Награды',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              '${unlocked.length}/${badges.length}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _BadgeTile(badge: badges[index], isDark: isDark);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.isDark});

  final MilestoneBadge badge;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;

    return Tooltip(
      message: badge.subtitle,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked
                ? badge.colors.first.withValues(alpha: 0.5)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: unlocked
                    ? LinearGradient(colors: badge.colors)
                    : null,
                color: unlocked
                    ? null
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 20,
                color: unlocked
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: unlocked
                    ? null
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
