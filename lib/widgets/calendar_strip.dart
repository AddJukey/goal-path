import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/day_entry.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    super.key,
    required this.calculator,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final GoalCalculator calculator;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = GoalCalculator.dateOnly(DateTime.now());
    final dates = _visibleDates(today);

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isToday = date == today;
          final isSelected = date == GoalCalculator.dateOnly(selectedDate);
          final data = calculator.getDayData(date);
          final hasData = data.amount > 0 || data.hours > 0;

          return _DayChip(
            date: date,
            isToday: isToday,
            isSelected: isSelected,
            hasData: hasData,
            isDark: isDark,
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }

  List<DateTime> _visibleDates(DateTime today) {
    final dates = <DateTime>[];
    for (var i = -10; i <= 10; i++) {
      final date = today.add(Duration(days: i));
      if (date.isBefore(GoalCalculator.dateOnly(calculator.settings.startDate))) {
        continue;
      }
      if (date.isAfter(GoalCalculator.dateOnly(calculator.settings.deadline))) {
        continue;
      }
      dates.add(date);
    }
    return dates;
  }
}

class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({
    super.key,
    required this.date,
    required this.entry,
  });

  final DateTime date;
  final DayEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = DateFormat('d MMMM', 'ru');
    final avg = entry.hours > 0
        ? '${entry.hourlyRate.toStringAsFixed(0)} ₽/ч'
        : '—';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mint.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmt.format(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (entry.notes.isNotEmpty)
                  Text(
                    entry.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
              ],
            ),
          ),
          _chip('${entry.hours.toStringAsFixed(1)} ч'),
          const SizedBox(width: 8),
          _chip('${entry.amount.toStringAsFixed(0)} ₽'),
          const SizedBox(width: 8),
          _chip(avg),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.mint,
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.hasData,
    required this.isDark,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool hasData;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    Color? bg;
    Color textColor;
    Border? border;

    if (isSelected) {
      bg = AppColors.mint;
      textColor = const Color(0xFF0A0A0F);
    } else if (isToday) {
      bg = AppColors.mint.withValues(alpha: 0.15);
      textColor = AppColors.mint;
      border = Border.all(color: AppColors.mint.withValues(alpha: 0.4));
    } else {
      bg = isDark ? AppColors.darkCard : AppColors.lightCard;
      textColor = isDark ? AppColors.darkText : AppColors.lightText;
      border = Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNames[date.weekday - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0A0A0F).withValues(alpha: 0.7)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasData
                    ? (isSelected ? const Color(0xFF0A0A0F) : AppColors.mint)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
