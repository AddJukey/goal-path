import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/day_entry.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';

class DayList extends StatelessWidget {
  const DayList({
    super.key,
    required this.calculator,
    required this.onDayChanged,
    required this.onDayCleared,
  });

  final GoalCalculator calculator;
  final void Function(DateTime date, DayEntry entry) onDayChanged;
  final void Function(DateTime date) onDayCleared;

  @override
  Widget build(BuildContext context) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: calculator.allDates.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final date = calculator.allDates[index];
          final data = calculator.getDayData(date);
          final isToday = date == today;
          final avg = data.hours > 0
              ? '${data.hourlyRate.toStringAsFixed(0)} ₽'
              : '—';

          return Container(
            color: isToday
                ? AppColors.accent.withValues(alpha: 0.35)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.day}.${date.month}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            dayNames[date.weekday - 1],
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _MiniField(
                            label: 'Ч',
                            value: data.hours,
                            onSubmitted: (v) => onDayChanged(
                              date,
                              data.copyWith(hours: v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _MiniField(
                            label: '₽',
                            value: data.amount,
                            onSubmitted: (v) => onDayChanged(
                              date,
                              data.copyWith(amount: v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              avg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onDayCleared(date),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 56, top: 4),
                  child: _NotesField(
                    key: ValueKey('${GoalCalculator.dateToKey(date)}_${data.notes}'),
                    notes: data.notes,
                    onSaved: (notes) => onDayChanged(
                      date,
                      data.copyWith(notes: notes),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotesField extends StatefulWidget {
  const _NotesField({
    super.key,
    required this.notes,
    required this.onSaved,
  });

  final String notes;
  final ValueChanged<String> onSaved;

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<_NotesField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.notes);
  }

  @override
  void didUpdateWidget(_NotesField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes &&
        _controller.text != widget.notes) {
      _controller.text = widget.notes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Заметка за день...',
        isDense: true,
        border: InputBorder.none,
      ),
      onSubmitted: widget.onSaved,
      onTapOutside: (_) => widget.onSaved(_controller.text.trim()),
    );
  }
}

class _MiniField extends StatefulWidget {
  const _MiniField({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String label;
  final double value;
  final ValueChanged<double> onSubmitted;

  @override
  State<_MiniField> createState() => _MiniFieldState();
}

class _MiniFieldState extends State<_MiniField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(_MiniField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text =
          widget.value == 0 ? '' : widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onSubmitted: (text) {
          final value = double.tryParse(text.replaceAll(',', '.')) ?? 0;
          widget.onSubmitted(value);
        },
      ),
    );
  }
}
