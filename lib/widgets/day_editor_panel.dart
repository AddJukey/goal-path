import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/day_entry.dart';
import '../services/goal_calculator.dart';
import '../services/voice_input_service.dart';
import '../theme/app_theme.dart';
import 'keyboard_toolbar.dart';
import 'mood_energy_picker.dart';
import 'ui/fb_widgets.dart';

class DayEditorPanel extends StatefulWidget {
  const DayEditorPanel({
    super.key,
    required this.date,
    required this.entry,
    required this.onSave,
    required this.onClear,
    this.onShiftSaved,
  });

  final DateTime date;
  final DayEntry entry;
  final Future<void> Function(DayEntry entry) onSave;
  final Future<void> Function() onClear;
  final Future<void> Function(DayEntry entry)? onShiftSaved;

  @override
  State<DayEditorPanel> createState() => _DayEditorPanelState();
}

class _DayEditorPanelState extends State<DayEditorPanel> {
  late final TextEditingController _hoursController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  final _voice = VoiceInputService();
  int? _mood;
  int? _energy;
  var _voiceBusy = false;

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
    _mood = widget.entry.mood;
    _energy = widget.entry.energy;
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

  DayEntry _buildEntry() {
    return DayEntry(
      hours: _parsedHours,
      amount: _parsedAmount,
      notes: _notesController.text.trim(),
      mood: _mood,
      energy: _energy,
    );
  }

  Future<void> _submit() async {
    KeyboardToolbarOverlay.dismiss(context);

    final entry = _buildEntry();

    if (entry.isEmpty) {
      await widget.onClear();
      return;
    }

    await widget.onSave(entry);
    await widget.onShiftSaved?.call(entry);
  }

  Future<void> _voiceInput() async {
    setState(() => _voiceBusy = true);
    try {
      final text = await _voice.listen();
      if (!mounted || text == null) return;
      final parsed = VoiceShiftParser.parse(text);
      if (parsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не распознано: $text')),
        );
        return;
      }
      if (parsed.hours > 0) {
        _hoursController.text = parsed.hours.toString();
      }
      if (parsed.amount > 0) {
        _amountController.text = parsed.amount.toStringAsFixed(0);
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _voiceBusy = false);
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = GoalCalculator.dateOnly(DateTime.now());
    final isToday = widget.date == today;
    final dateLabel = isToday
        ? 'Сегодня, ${DateFormat('d MMMM', 'ru').format(widget.date)}'
        : DateFormat('EEEE, d MMMM', 'ru').format(widget.date);

    return FbCard(
      title: dateLabel,
      icon: Icons.edit_calendar_outlined,
      iconColor: AppColors.mint,
      trailing: _liveRate != '—'
          ? FbBadge(label: _liveRate, color: AppColors.mint, small: true)
          : null,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _field(
                  label: '⏱️ Часы',
                  controller: _hoursController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  label: '💰 Сумма (₽)',
                  controller: _amountController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _voiceBusy ? null : _voiceInput,
              icon: _voiceBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.mic_none_rounded, size: 18),
              label: const Text('Голосом'),
            ),
          ),
          const SizedBox(height: 12),
          MoodEnergyPicker(
            mood: _mood,
            energy: _energy,
            onMoodChanged: (v) => setState(() => _mood = v),
            onEnergyChanged: (v) => setState(() => _energy = v),
          ),
          const SizedBox(height: 12),
          Text('📝 Заметка', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          TextField(
            controller: _notesController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onTapOutside: (_) => KeyboardToolbarOverlay.dismiss(context),
            decoration: const InputDecoration(
              hintText: 'Комментарий к смене...',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!widget.entry.isEmpty)
                OutlinedButton.icon(
                  onPressed: () async {
                    KeyboardToolbarOverlay.dismiss(context);
                    await widget.onClear();
                    _hoursController.clear();
                    _amountController.clear();
                    _notesController.clear();
                    setState(() {
                      _mood = null;
                      _energy = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Очистить'),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check, size: 18),
                label: Text(widget.entry.isEmpty ? 'Сохранить' : 'Обновить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
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
          decoration: const InputDecoration(hintText: '0'),
        ),
      ],
    );
  }
}
