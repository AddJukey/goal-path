import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/insights_models.dart';
import '../theme/app_theme.dart';

class PeriodComparisonCard extends StatelessWidget {
  const PeriodComparisonCard({super.key, required this.comparison});

  final PeriodComparison comparison;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberFormat = NumberFormat.decimalPattern('ru');

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
            'Сравнение периодов',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${_capitalize(comparison.currentLabel)} vs ${_capitalize(comparison.previousLabel)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),
          if (!comparison.hasPreviousData)
            Text(
              'В прошлом месяце нет данных для сравнения.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
          else
            ...comparison.metrics.map((m) {
              final improved = m.improved;
              final declined = m.declined;
              final color = improved
                  ? AppColors.mint
                  : (declined ? const Color(0xFFEF4444) : AppColors.blue);

              final displayCurrent = m.unit == '₽'
                  ? '${numberFormat.format(m.current.floor())}${m.unit}'
                  : m.unit == 'ч' || m.unit == 'дн'
                      ? '${m.current.toStringAsFixed(m.unit == 'дн' ? 0 : 1)} ${m.unit}'
                      : '${m.current.toStringAsFixed(0)} ${m.unit}';

              final sign = m.delta >= 0 ? '+' : '';
              final deltaText = m.unit == '₽'
                  ? '$sign${numberFormat.format(m.delta.floor())}${m.unit}'
                  : '$sign${m.delta.toStringAsFixed(m.unit == 'дн' ? 0 : 1)} ${m.unit}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            displayCurrent,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          deltaText,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: color,
                          ),
                        ),
                        if (m.previous != 0)
                          Text(
                            '${m.deltaPercent >= 0 ? '+' : ''}${m.deltaPercent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: color.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
