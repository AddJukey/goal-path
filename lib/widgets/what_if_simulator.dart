import 'package:flutter/material.dart';

import '../models/insights_models.dart';
import '../services/goal_calculator.dart';
import '../services/insights_service.dart';
import '../theme/app_theme.dart';

class WhatIfSimulator extends StatefulWidget {
  const WhatIfSimulator({super.key, required this.calculator});

  final GoalCalculator calculator;

  @override
  State<WhatIfSimulator> createState() => _WhatIfSimulatorState();
}

class _WhatIfSimulatorState extends State<WhatIfSimulator> {
  double _extraHours = 0;
  double _extraRate = 0;
  final _insights = InsightsService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _insights.simulate(
      widget.calculator,
      extraHoursPerDay: _extraHours,
      extraRatePerHour: _extraRate,
    );

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
            'Симулятор «что если»',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Подкрутите темп — увидите новую дату цели',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: '+ часов в день',
            value: _extraHours,
            min: 0,
            max: 4,
            divisions: 8,
            suffix: 'ч',
            color: AppColors.blue,
            onChanged: (v) => setState(() => _extraHours = v),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: '+ к ставке',
            value: _extraRate,
            min: 0,
            max: 500,
            divisions: 10,
            suffix: '₽/ч',
            color: AppColors.mint,
            onChanged: (v) => setState(() => _extraRate = v),
          ),
          const SizedBox(height: 16),
          _ResultBox(result: result),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(
              '+${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $suffix',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.result});

  final WhatIfResult result;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = result.isAchievable ? AppColors.mint : AppColors.purple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дата достижения',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (result.dailyIncome > 0) ...[
            const SizedBox(height: 6),
            Text(
              '~${result.dailyIncome.toStringAsFixed(0)}₽/день · '
              '${result.daysNeeded.toStringAsFixed(0)} дн.',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
