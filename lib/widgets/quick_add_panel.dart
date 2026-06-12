import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class QuickAddPanel extends StatefulWidget {
  const QuickAddPanel({
    super.key,
    required this.onAdd,
  });

  final Future<void> Function({
    required double hours,
    required double amount,
    required String notes,
  }) onAdd;

  @override
  State<QuickAddPanel> createState() => _QuickAddPanelState();
}

class _QuickAddPanelState extends State<QuickAddPanel> {
  final _hoursController = TextEditingController(text: '0');
  final _amountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _hoursController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final hours = double.tryParse(_hoursController.text.replaceAll(',', '.')) ?? 0;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final notes = _notesController.text.trim();

    if (hours == 0 && amount == 0) return;

    await widget.onAdd(hours: hours, amount: amount, notes: notes);

    _hoursController.text = '0';
    _amountController.text = '0';
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                _LabeledField(
                  label: '⏱️ Часы',
                  controller: _hoursController,
                  width: 100,
                ),
                _LabeledField(
                  label: '💰 Сумма (₽)',
                  controller: _amountController,
                  width: 120,
                ),
                SizedBox(
                  width: 200,
                  child: _LabeledField(
                    label: '📝 Заметка',
                    controller: _notesController,
                    width: 200,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFF1E2A3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить смену'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.width,
  });

  final String label;
  final TextEditingController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            decoration: const InputDecoration(
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
