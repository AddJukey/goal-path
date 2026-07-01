import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/goal_settings.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';

class GoalSettingsPanel extends StatefulWidget {
  const GoalSettingsPanel({
    super.key,
    required this.settings,
    required this.calculator,
    required this.onChanged,
  });

  final GoalSettings settings;
  final GoalCalculator calculator;
  final ValueChanged<GoalSettings> onChanged;

  @override
  State<GoalSettingsPanel> createState() => _GoalSettingsPanelState();
}

class _GoalSettingsPanelState extends State<GoalSettingsPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.settings.title);
    _targetController = TextEditingController(
      text: widget.settings.targetAmount.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(GoalSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.title != widget.settings.title) {
      _titleController.text = widget.settings.title;
    }
    if (oldWidget.settings.targetAmount != widget.settings.targetAmount) {
      _targetController.text = widget.settings.targetAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _emit() {
    final target = double.tryParse(_targetController.text) ?? widget.settings.targetAmount;
    widget.onChanged(
      widget.settings.copyWith(
        title: _titleController.text.trim().isEmpty
            ? 'Моя цель'
            : _titleController.text.trim(),
        targetAmount: target,
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.settings.deadline,
      firstDate: widget.settings.startDate,
      lastDate: DateTime(widget.settings.startDate.year + 5),
      locale: const Locale('ru'),
    );
    if (picked != null) {
      widget.onChanged(
        widget.settings.copyWith(
          deadline: DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
        ),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.settings.startDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      locale: const Locale('ru'),
      helpText: 'Когда начали копить?',
    );
    if (picked != null) {
      final start = DateTime(picked.year, picked.month, picked.day);
      var settings = widget.settings.copyWith(startDate: start);
      if (settings.deadline.isBefore(start)) {
        settings = settings.copyWith(
          deadline: DateTime(start.year, start.month + 6, start.day, 23, 59, 59),
        );
      }
      widget.onChanged(settings);
    }
  }

  int get _daysSaving {
    final start = GoalCalculator.dateOnly(widget.settings.startDate);
    final today = GoalCalculator.dateOnly(DateTime.now());
    return today.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final countdown = widget.calculator.timeUntilDeadline;
    final deadlineText = countdown == null
        ? 'Время вышло!'
        : widget.calculator.formatDeadlineCountdown(countdown);
    final deadlineFormatted =
        DateFormat('dd.MM.yyyy').format(widget.settings.deadline);
    final startFormatted =
        DateFormat('dd.MM.yyyy').format(widget.settings.startDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _field(
              label: '🎯 Название цели',
              child: TextField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _emit(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(isDense: true),
              ),
              width: 180,
            ),
            _field(
              label: '🎯 Цель (₽)',
              child: TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _emit(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(isDense: true),
              ),
              width: 140,
            ),
            _field(
              label: '📆 Начал копить ($startFormatted)',
              child: OutlinedButton.icon(
                onPressed: _pickStartDate,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: Text('$_daysSaving дн.'),
              ),
              width: 180,
            ),
            _field(
              label: '📅 Дедлайн ($deadlineFormatted)',
              child: OutlinedButton(
                onPressed: _pickDeadline,
                child: const Text('Изменить дату'),
              ),
              width: 160,
            ),
            _field(
              label: '⏱️ Осталось',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  deadlineText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3E),
                  ),
                ),
              ),
              width: 140,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required Widget child,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
