import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/coach_models.dart';

class ScriptedCoachService {
  ScriptedCoachService() : _random = Random();

  final Random _random;
  Map<String, List<String>>? _quotes;

  Future<void> _ensureLoaded() async {
    if (_quotes != null) return;
    final raw = await rootBundle.loadString('assets/data/quotes_ru.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _quotes = map.map(
      (k, v) => MapEntry(k, List<String>.from(v as List)),
    );
  }

  Future<CoachMessage> message(
    CoachContext context, {
    required CoachMessageKind kind,
  }) async {
    await _ensureLoaded();
    final key = context.situation.name;
    final pool = _quotes![key] ?? _quotes!['dailyTip']!;
    final text = pool[_random.nextInt(pool.length)];

    if (kind == CoachMessageKind.moodInsight &&
        context.moodEarningsHint.isNotEmpty) {
      return CoachMessage(
        text: '${context.moodEarningsHint}. $text',
        kind: kind,
        source: CoachMessageSource.scripted,
        situation: context.situation,
      );
    }

    return CoachMessage(
      text: text,
      kind: kind,
      source: CoachMessageSource.scripted,
      situation: context.situation,
    );
  }

  CoachMessage adviceScripted(CoachContext context) {
    final tips = <String, String>{
      'behindPace':
          'Попробуйте добавить 1 короткую смену на этой неделе — темп выровняется.',
      'aheadPace': 'Вы опережаете план. Можно чуть снизить нагрузку без риска для цели.',
      'streakBroken':
          'Серия сброшена — отметьте сегодня хотя бы 2 часа, чтобы начать новую.',
      'goalNear':
          'До цели осталось немного. Держите ритм ещё 2–3 недели.',
      'lowMood':
          'Низкое настроение бывает. Отметьте смену и отдохните — прогресс не исчезает.',
      'dailyTip':
          'Сравнивайте себя с прошлой неделей, а не с идеальным планом.',
    };
    final text = tips[context.situation.name] ?? tips['dailyTip']!;
    return CoachMessage(
      text: text,
      kind: CoachMessageKind.advice,
      source: CoachMessageSource.scripted,
      situation: context.situation,
    );
  }
}
