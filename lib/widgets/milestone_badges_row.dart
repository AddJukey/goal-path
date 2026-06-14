import 'package:flutter/material.dart';

import '../models/milestone_badge.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class MilestoneBadgesRow extends StatelessWidget {
  const MilestoneBadgesRow({
    super.key,
    required this.badges,
  });

  final List<MilestoneBadge> badges;

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((b) => b.unlocked).length;

    return FbCard(
      title: 'Награды',
      icon: Icons.military_tech_outlined,
      iconColor: AppColors.october,
      trailing: FbBadge(
        label: '$unlocked/${badges.length}',
        color: AppColors.mint,
        small: true,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: badges.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return _BadgeTile(badge: badges[index]);
          },
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final MilestoneBadge badge;

  @override
  Widget build(BuildContext context) {
    final dark = AppDecorations.isDark(context);
    final unlocked = badge.unlocked;

    return Tooltip(
      message: badge.subtitle,
      child: Container(
        width: 76,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCardElevated : AppColors.lightInputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: unlocked
                ? badge.colors.first.withValues(alpha: 0.5)
                : (dark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient:
                    unlocked ? LinearGradient(colors: badge.colors) : null,
                color: unlocked
                    ? null
                    : (dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 18,
                color: unlocked
                    ? Colors.white
                    : AppColors.lightTextSecondary,
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
                color: unlocked ? null : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
