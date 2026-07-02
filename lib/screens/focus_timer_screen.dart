import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/goal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/fb_widgets.dart';

enum _FocusPhase { idle, focus, breakTime, paused }

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  _FocusPhase _phase = _FocusPhase.idle;
  int _secondsLeft = 0;
  int _focusMinutes = 25;
  int _breakMinutes = 5;

  void _tick() {
    if (_phase != _FocusPhase.focus && _phase != _FocusPhase.breakTime) return;
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_phase != _FocusPhase.focus && _phase != _FocusPhase.breakTime) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _onPhaseComplete();
          return;
        }
      });
      _tick();
    });
  }

  void _onPhaseComplete() {
    if (_phase == _FocusPhase.focus) {
      _phase = _FocusPhase.breakTime;
      _secondsLeft = _breakMinutes * 60;
      _showCompleteDialog(focusDone: true);
    } else {
      _phase = _FocusPhase.idle;
      _secondsLeft = 0;
    }
    setState(() {});
    if (_phase == _FocusPhase.breakTime) _tick();
  }

  Future<void> _showCompleteDialog({required bool focusDone}) async {
    if (!focusDone || !mounted) return;
    final provider = context.read<GoalProvider>();
    final hours = _focusMinutes / 60.0;

    final add = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сессия завершена'),
        content: Text(
          'Добавить $_focusMinutes мин (${hours.toStringAsFixed(2)} ч) в сегодняшнюю смену?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    if (add == true) {
      await provider.addShiftToday(hours: hours, amount: 0, notes: 'Фокус-сессия');
    }
  }

  void _startFocus() {
    setState(() {
      _phase = _FocusPhase.focus;
      _secondsLeft = _focusMinutes * 60;
    });
    _tick();
  }

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<GoalProvider>().appPreferences;
    _focusMinutes = prefs.focusMinutes;
    _breakMinutes = prefs.breakMinutes;

    final phaseLabel = switch (_phase) {
      _FocusPhase.focus => 'Фокус',
      _FocusPhase.breakTime => 'Перерыв',
      _FocusPhase.paused => 'Пауза',
      _ => 'Готов к работе',
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FbSectionTitle(
            title: 'Таймер фокуса',
            subtitle: 'Pomodoro для смены. После сессии — добавить часы в смену.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: AppDecorations.heroGradient(context),
            child: Column(
              children: [
                Text(phaseLabel, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Text(
                  _phase == _FocusPhase.idle
                      ? '${_focusMinutes.toString().padLeft(2, '0')}:00'
                      : _timeLabel,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_phase == _FocusPhase.idle)
                      FilledButton.icon(
                        onPressed: _startFocus,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Старт'),
                      )
                    else ...[
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _phase = _FocusPhase.idle;
                            _secondsLeft = 0;
                          });
                        },
                        child: const Text('Стоп'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FbCard(
            title: 'Как это работает',
            icon: Icons.info_outline,
            child: Text(
              '$_focusMinutes мин работы → $_breakMinutes мин перерыв. '
              'Настройки длительности — в блоке «Plime Coach» на главном экране.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
