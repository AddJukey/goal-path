import '../models/balance_segment.dart';
import '../theme/app_theme.dart';
import 'goal_calculator.dart';
import 'statistics_service.dart';
import '../models/period_stats.dart';

class BalanceService {
  GoalBalance compute(GoalCalculator calculator) {
    final target = calculator.settings.targetAmount;
    final earned = calculator.totalStats.totalAmount;
    final earnedPercent =
        target > 0 ? (earned / target * 100).clamp(0, 100) : 0;

    final monthReport =
        StatisticsService().report(calculator, StatsPeriod.month);
    final pacePercent = monthReport.averagePercent.clamp(0, 100);

    final last7 = calculator.last7DaysStats;
    final expectedWeeklyHours = 42.0;
    final hoursPercent = last7.hours > 0
        ? (last7.hours / expectedWeeklyHours * 100).clamp(0, 100)
        : 0;

    final segments = <BalanceSegment>[
      BalanceSegment(
        label: 'Заработок',
        percent: earnedPercent.toDouble(),
        color: AppColors.mint,
        detail: '${earnedPercent.toStringAsFixed(0)}% цели',
      ),
      BalanceSegment(
        label: 'Темп месяца',
        percent: pacePercent.toDouble(),
        color: AppColors.blue,
        detail: '${pacePercent.toStringAsFixed(0)}% плана',
      ),
      BalanceSegment(
        label: 'Часы (7 дн)',
        percent: hoursPercent.toDouble(),
        color: AppColors.purple,
        detail: '${last7.hours.toStringAsFixed(0)} ч',
      ),
    ];

    final active = segments.where((s) => s.percent > 0).toList();
    final overall = active.isEmpty
        ? earnedPercent.toDouble()
        : active.fold<double>(0, (sum, s) => sum + s.percent) / active.length;

    return GoalBalance(
      overallPercent: overall.clamp(0, 100),
      segments: active,
    );
  }
}
