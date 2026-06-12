import 'package:flutter/material.dart';

import '../models/period_stats.dart';
import '../services/statistics_service.dart';
import '../theme/app_theme.dart';

class AchievementChart extends StatelessWidget {
  const AchievementChart({
    super.key,
    required this.report,
    this.height = 160,
  });

  final PeriodAchievementReport report;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = report.points;

    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Нет данных за период',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    final maxPercent = points
        .map((p) => p.achievementPercent)
        .fold<double>(0, (a, b) => a > b ? a : b)
        .clamp(100.0, double.infinity);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _YAxis(maxPercent: maxPercent, isDark: isDark),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                final barHeight =
                    (point.achievementPercent / maxPercent).clamp(0.0, 1.0);
                final showLabel = _shouldShowLabel(point, points.length);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (point.achievementPercent > 0)
                          Text(
                            '${point.achievementPercent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 8,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: barHeight == 0 ? 0.04 : barHeight,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: point.achievementPercent > 0
                                        ? AppColors.chartGradient
                                        : [
                                            (isDark
                                                ? AppColors.darkProgressBg
                                                : AppColors.lightProgressBg),
                                            (isDark
                                                ? AppColors.darkProgressBg
                                                : AppColors.lightProgressBg),
                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (showLabel)
                          Text(
                            StatisticsService.pointLabel(
                              point,
                              report.period,
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowLabel(DayAchievement point, int count) {
    if (report.period == StatsPeriod.year) return true;
    if (count <= 7) return true;
    if (count <= 14) return point.date.day % 2 == 0;
    return point.date.day % 5 == 0;
  }
}

class _YAxis extends StatelessWidget {
  const _YAxis({required this.maxPercent, required this.isDark});

  final double maxPercent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final labels = [
      '${maxPercent.toStringAsFixed(0)}%',
      '${(maxPercent / 2).toStringAsFixed(0)}%',
      '0%',
    ];

    return SizedBox(
      width: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: labels
            .map(
              (l) => Text(
                l,
                style: TextStyle(fontSize: 9, color: color),
              ),
            )
            .toList(),
      ),
    );
  }
}
