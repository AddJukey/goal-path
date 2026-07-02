import 'package:speech_to_text/speech_to_text.dart';

/// Parses Russian voice like «6 часов 3500 рублей».
class VoiceShiftParser {
  static ({double hours, double amount})? parse(String text) {
    final lower = text.toLowerCase().replaceAll('ё', 'е');
    if (lower.trim().isEmpty) return null;

    double? hours;
    double? amount;

    final hoursMatch = RegExp(
      r'(\d+[.,]?\d*)\s*(час|часа|часов|ч\b)',
    ).firstMatch(lower);
    if (hoursMatch != null) {
      hours = double.tryParse(hoursMatch.group(1)!.replaceAll(',', '.'));
    }

    final amountMatch = RegExp(
      r'(\d[\d\s]{0,8}\d|\d+)\s*(руб|₽|р\b)',
    ).firstMatch(lower);
    if (amountMatch != null) {
      final raw = amountMatch.group(1)!.replaceAll(' ', '');
      amount = double.tryParse(raw.replaceAll(',', '.'));
    }

    if (hours == null) {
      final lone = RegExp(r'^(\d+[.,]?\d*)$').firstMatch(lower.trim());
      hours = lone != null
          ? double.tryParse(lone.group(1)!.replaceAll(',', '.'))
          : null;
    }

    if (hours == null && amount == null) return null;
    return (hours: hours ?? 0, amount: amount ?? 0);
  }
}

class VoiceInputService {
  VoiceInputService() : _speech = SpeechToText();

  final SpeechToText _speech;
  bool _ready = false;

  Future<bool> init() async {
    _ready = await _speech.initialize();
    return _ready;
  }

  bool get isAvailable => _ready;

  Future<String?> listen({Duration timeout = const Duration(seconds: 8)}) async {
    if (!_ready) {
      final ok = await init();
      if (!ok) return null;
    }

    final completer = StringBuffer();
    var finished = false;

    await _speech.listen(
      localeId: 'ru_RU',
      listenFor: timeout,
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        completer.clear();
        completer.write(result.recognizedWords);
        if (result.finalResult) finished = true;
      },
    );

    final deadline = DateTime.now().add(timeout + const Duration(seconds: 1));
    while (!finished && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!_speech.isListening && completer.isNotEmpty) break;
    }

    await _speech.stop();
    final text = completer.toString().trim();
    return text.isEmpty ? null : text;
  }

  void dispose() {
    _speech.stop();
  }
}
