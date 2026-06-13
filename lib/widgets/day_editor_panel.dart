import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/day_entry.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';
import 'keyboard_toolbar.dart';

class DayEditorPanel extends StatefulWidget {
  const DayEditorPanel({
    super.key,
    required this.date,
    required this.entry,
    required this.onSave,
    required this.onClear,
  });

  final DateTime date;
  final DayEntry entry;
  final Future<void> Function(DayEntry entry) onSave;
  final Future<void> Function() onClear;

  @override
  State<DayEditorPanel> createState() => _DayEditorPanelState();
}

class _DayEditorPanelState extends State<DayEditorPanel> {
  late final TextEditingController _hoursController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
    _syncFromEntry();
    _hoursController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  @override
  void didUpdateWidget(DayEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date ||
        oldWidget.entry != widget.entry) {
      _syncFromEntry();
    }
  }

  void _syncFromEntry() {
    _hoursController.text =
        widget.entry.hours > 0 ? widget.entry.hours.toString() : '';
    _amountController.text =
        widget.entry.amount > 0 ? widget.entry.amount.toStringAsFixed(0) : '';
    _notesController.text = widget.entry.notes;
  }

  void _onFieldChanged() => setState(() {});

  double get _parsedHours =>
      double.tryParse(_hoursController.text.replaceAll(',', '.')) ?? 0;

  double get _parsedAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

  String get _liveRate {
    if (_parsedHours <= 0 || _parsedAmount <= 0) return '—';
    return '${(_parsedAmount / _parsedHours).toStringAsFixed(0)} ₽/ч';
  }

  Future<void> _submit() async {
    KeyboardToolbarOverlay.dismiss(context);

    final hours = _parsedHours;
    final amount = _parsedAmount;
    final notes = _notesController.text.trim();

    if (hours == 0 && amount == 0 && notes.isEmpty) {
      await widget.onClear();
      return;
    }

    await widget.onSave(
      DayEntry(hours: hours, amount: amount, notes: notes),
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = GoalCalculator.dateOnly(DateTime.now());
    final isToday = widget.date == today;
    final dateLabel = isToday
        ? 'Сегодня, ${DateFormat('d MMMM', 'ru').format(widget.date)}'
        : DateFormat('EEEE, d MMMM', 'ru').format(widget.date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (_liveRate != '—')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _liveRate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.mint,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _field(
                    label: '⏱️ Часы',
                    controller: _hoursController,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    label: '💰 Сумма (₽)',
                    controller: _amountController,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '📝 Заметка',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _notesController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) => KeyboardToolbarOverlay.dismiss(context),
              decoration: const InputDecoration(
                hintText: 'Комментарий к смене...',
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (widget.entry.hours > 0 ||
                    widget.entry.amount > 0 ||
                    widget.entry.notes.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      KeyboardToolbarOverlay.dismiss(context);
                      await widget.onClear();
                      _hoursController.clear();
                      _amountController.clear();
                      _notesController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Очистить'),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: const Color(0xFF0A0A0F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(widget.entry.isEmpty ? 'Сохранить' : 'Обновить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          onSubmitted: (_) => _submit(),
          onTapOutside: (_) => KeyboardToolbarOverlay.dismiss(context),
          decoration: InputDecoration(
            isDense: true,
            hintText: '0',
            filled: true,
            fillColor: isDark ? AppColors.darkCardElevated : AppColors.lightBg,
          ),
        ),
      ],
    );
  }
}
