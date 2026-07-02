import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/coach_models.dart';

/// Calls your Cloudflare Worker (`AI_WORKER_URL` dart-define).
class CloudflareAiService {
  CloudflareAiService({http.Client? client}) : _client = client ?? http.Client();

  static const workerUrl = String.fromEnvironment(
    'AI_WORKER_URL',
    defaultValue: '',
  );

  final http.Client _client;

  bool get isConfigured => workerUrl.isNotEmpty;

  Future<String?> complete({
    required String type,
    required CoachContext context,
  }) async {
    if (!isConfigured) return null;

    try {
      final response = await _client
          .post(
            Uri.parse(workerUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'type': type,
              'situation': context.situation.name,
              'context': context.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        debugPrint('Cloudflare AI HTTP ${response.statusCode}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (body['text'] as String?)?.trim();
      if (text == null || text.isEmpty) return null;
      return text.length > 280 ? '${text.substring(0, 277)}...' : text;
    } catch (e) {
      debugPrint('Cloudflare AI error: $e');
      return null;
    }
  }
}
