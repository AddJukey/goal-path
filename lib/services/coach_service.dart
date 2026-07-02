import 'dart:math';

import '../models/app_preferences.dart';
import '../models/coach_models.dart';
import 'cloudflare_ai_service.dart';
import 'scripted_coach_service.dart';

class CoachService {
  CoachService({
    ScriptedCoachService? scripted,
    CloudflareAiService? cloudflare,
  })  : _scripted = scripted ?? ScriptedCoachService(),
        _cloudflare = cloudflare ?? CloudflareAiService(),
        _random = Random();

  final ScriptedCoachService _scripted;
  final CloudflareAiService _cloudflare;
  final Random _random;

  bool get aiAvailable => _cloudflare.isConfigured;

  Future<CoachMessage> quoteAfterShift(
    CoachContext context,
    AppPreferences prefs,
  ) {
    return _resolve(
      context,
      prefs,
      kind: CoachMessageKind.quote,
      aiType: 'quote',
    );
  }

  Future<CoachMessage> dailyAdvice(
    CoachContext context,
    AppPreferences prefs,
  ) {
    return _resolve(
      context,
      prefs,
      kind: CoachMessageKind.advice,
      aiType: 'advice',
    );
  }

  Future<CoachMessage> moodInsight(
    CoachContext context,
    AppPreferences prefs,
  ) {
    return _resolve(
      context,
      prefs,
      kind: CoachMessageKind.moodInsight,
      aiType: 'mood',
    );
  }

  Future<CoachMessage> _resolve(
    CoachContext context,
    AppPreferences prefs, {
    required CoachMessageKind kind,
    required String aiType,
  }) async {
    if (_shouldUseScripted(prefs)) {
      if (kind == CoachMessageKind.advice) {
        return _scripted.adviceScripted(context);
      }
      return _scripted.message(context, kind: kind);
    }

    final aiText = await _cloudflare.complete(type: aiType, context: context);
    if (aiText != null) {
      return CoachMessage(
        text: aiText,
        kind: kind,
        source: CoachMessageSource.ai,
        situation: context.situation,
      );
    }

    if (kind == CoachMessageKind.advice) {
      return _scripted.adviceScripted(context);
    }
    return _scripted.message(context, kind: kind);
  }

  bool _shouldUseScripted(AppPreferences prefs) {
    if (prefs.offlineCoachOnly || !prefs.smartCoachEnabled) return true;
    if (!_cloudflare.isConfigured) return true;
    final mix = prefs.scriptedMixPercent.clamp(0, 100);
    if (mix > 0 && _random.nextInt(100) < mix) return true;
    return false;
  }
}
