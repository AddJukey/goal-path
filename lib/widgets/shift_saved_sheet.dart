import 'package:flutter/material.dart';

import '../models/coach_models.dart';
import '../theme/app_theme.dart';

class ShiftSavedSheet extends StatelessWidget {
  const ShiftSavedSheet({
    super.key,
    required this.message,
    required this.loading,
  });

  final CoachMessage? message;
  final bool loading;

  static Future<void> show(
    BuildContext context, {
    required Future<CoachMessage> messageFuture,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _ShiftSavedSheetBody(messageFuture: messageFuture),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ShiftSavedSheetBody extends StatefulWidget {
  const _ShiftSavedSheetBody({required this.messageFuture});

  final Future<CoachMessage> messageFuture;

  @override
  State<_ShiftSavedSheetBody> createState() => _ShiftSavedSheetBodyState();
}

class _ShiftSavedSheetBodyState extends State<_ShiftSavedSheetBody> {
  CoachMessage? _message;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    widget.messageFuture.then((m) {
      if (mounted) {
        setState(() {
          _message = m;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 28),
              const SizedBox(width: 10),
              Text(
                'Смена сохранена',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Text(
              _message?.text ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              _message?.isAi == true
                  ? 'Plime Coach · ИИ'
                  : 'Plime Coach · офлайн',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mint,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отлично'),
          ),
        ],
      ),
    );
  }
}
