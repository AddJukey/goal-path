import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/period_stats.dart';
import '../providers/goal_provider.dart';
import '../services/badge_service.dart';
import '../services/balance_service.dart';
import '../services/insights_service.dart';
import '../services/statistics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_chart.dart';
import '../widgets/balance_ring_chart.dart';
import '../widgets/best_day_card.dart';
import '../widgets/confidence_forecast_card.dart';
import '../widgets/milestone_badges_row.dart';
import '../widgets/period_comparison_card.dart';
import '../widgets/what_if_simulator.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.month;
  final _stats = StatisticsService();
  final _insights = InsightsService();

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        final calculator = provider.calculator;
        final report = _stats.report(calculator, _period);
        final balance = BalanceService().compute(calculator);
        final badges = BadgeService().badges(calculator);
        final bestDay = _insights.bestDayOfWeek(calculator);
        final forecast = _insights.confidenceForecast(calculator);
        final comparison = _insights.monthComparison(calculator);
        final numberFormat = NumberFormat.decimalPattern('ru');
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Статистика',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: 16),
            _PeriodTabs(
              selected: _period,
              onChanged: (p) => setState(() => _period = p),
            ),
            const SizedBox(height: 16),
            Container(
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
                    'Баланс цели',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  BalanceRingChart(
                    segments: balance.segments,
                    centerValue:
                        '${balance.overallPercent.toStringAsFixed(0)}%',
                    centerLabel: 'общий баланс',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MilestoneBadgesRow(badges: badges),
            const SizedBox(height: 16),
            BestDayCard(insight: bestDay),
            const SizedBox(height: 12),
            ConfidenceForecastCard(forecast: forecast),
            const SizedBox(height: 12),
            WhatIfSimulator(calculator: calculator),
            const SizedBox(height: 12),
            PeriodComparisonCard(comparison: comparison),
            const SizedBox(height: 16),
            _HeroCard(
              title: 'Процент выполнения',
              subtitle: StatisticsService.formatPeriodRange(report),
              average: report.averagePercent,
              child: AchievementChart(report: report),
            ),
            const SizedBox(height: 12),
            _HeroCard(
              title: 'Заработок за период',
              subtitle: StatisticsService.formatPeriodRange(report),
              average: report.goalSharePercent,
              averageLabel: 'от цели',
              accentColor: AppColors.purple,
              child: AchievementChart(
                report: _earningsReport(report),
                height: 140,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Заработано',
                    value: '${numberFormat.format(report.totalAmount.floor())}₽',
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Часов',
                    value: report.totalHours.toStringAsFixed(1),
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Активных дней',
                    value: '${report.activeDays}',
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Доля цели',
                    value: '${report.goalSharePercent.toStringAsFixed(1)}%',
                    color: AppColors.mintDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Text(
                _periodInsight(report),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  PeriodAchievementReport _earningsReport(PeriodAchievementReport report) {
    final maxAmount = report.points
        .map((p) => p.amount)
        .fold<double>(0, (a, b) => a > b ? a : b);

    final points = report.points.map((p) {
      final percent = maxAmount > 0 ? (p.amount / maxAmount) * 100 : 0.0;
      return DayAchievement(
        date: p.date,
        amount: p.amount,
        hours: p.hours,
        dailyTarget: p.dailyTarget,
        achievementPercent: percent,
      );
    }).toList();

    return PeriodAchievementReport(
      period: report.period,
      start: report.start,
      end: report.end,
      points: points,
      averagePercent: report.goalSharePercent,
      totalAmount: report.totalAmount,
      totalHours: report.totalHours,
      goalSharePercent: report.goalSharePercent,
      activeDays: report.activeDays,
    );
  }

  String _periodInsight(PeriodAchievementReport report) {
    final periodName = switch (report.period) {
      StatsPeriod.week => 'за неделю',
      StatsPeriod.month => 'за месяц',
      StatsPeriod.year => 'за год',
    };

    if (report.activeDays == 0) {
      return 'Пока нет записей $periodName. Добавь смену на вкладке «Сегодня».';
    }

    return 'Среднее выполнение плана $periodName — '
        '${report.averagePercent.toStringAsFixed(0)}%. '
        'Ты заработал ${report.totalAmount.toStringAsFixed(0)}₽ '
        '(${report.goalSharePercent.toStringAsFixed(1)}% от цели).';
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({
    required this.selected,
    required this.onChanged,
  });

  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _tab('Неделя', StatsPeriod.week, isDark),
          _tab('Месяц', StatsPeriod.month, isDark),
          _tab('Год', StatsPeriod.year, isDark),
        ],
      ),
    );
  }

  Widget _tab(String label, StatsPeriod period, bool isDark) {
    final isSelected = selected == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.mint.withValues(alpha: isDark ? 0.2 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
              color: isSelected
                  ? AppColors.mint
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.average,
    required this.child,
    this.averageLabel = 'среднее',
    this.accentColor = AppColors.mint,
  });

  final String title;
  final String subtitle;
  final double average;
  final String averageLabel;
  final Color accentColor;
  final Widget child;

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '${average.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
