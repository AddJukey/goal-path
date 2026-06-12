import 'package:flutter/material.dart';

import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({
    super.key,
    required this.calculator,
  });

  final GoalCalculator calculator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressBg =
        isDark ? AppColors.darkProgressBg : AppColors.lightProgressBg;
    final total = calculator.totalStats.totalAmount;
    final target = calculator.settings.targetAmount;
    final percent = target > 0 ? (total / target).clamp(0.0, 1.0) : 0.0;
    final stats = calculator.totalStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 24,
                backgroundColor: progressBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.mint),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: calculator.milestones.map((milestone) {
                final done = total >= milestone;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFF2ECC71)
                        : (isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${milestone ~/ 1000}k',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: done ? Colors.white : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _ForecastChip(
                  label: '📈 Оптимист (12ч/день)',
                  value: calculator.forecastOptimist,
                ),
                _ForecastChip(
                  label: '📉 Пессимист (твой темп)',
                  value: calculator.forecastPessimist,
                ),
                _ForecastChip(
                  label: '💰 Средняя ставка',
                  value: '${stats.avgRate.toStringAsFixed(0)} ₽/ч',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastChip extends StatelessWidget {
  const _ForecastChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 12,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
    );
  }
}
