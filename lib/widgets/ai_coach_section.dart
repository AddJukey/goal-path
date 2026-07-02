import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coach_models.dart';
import '../providers/goal_provider.dart';
import '../services/cloudflare_ai_service.dart';
import '../services/coach_service.dart';
import '../services/situation_detector.dart';
import 'ai_coach_card.dart';

class AiCoachSection extends StatefulWidget {
  const AiCoachSection({super.key});

  @override
  State<AiCoachSection> createState() => _AiCoachSectionState();
}

class _AiCoachSectionState extends State<AiCoachSection> {
  final _coach = CoachService();
  final _detector = SituationDetector();
  CoachMessage? _message;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final provider = context.read<GoalProvider>();
    final ctx = _detector.buildDailyTip(provider.calculator);
    final msg = await _coach.dailyAdvice(ctx, provider.appPreferences);
    if (mounted) {
      setState(() {
        _message = msg;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AiCoachCard(
      message: _message,
      loading: _loading,
      aiConfigured: CloudflareAiService().isConfigured,
      onRefresh: _load,
    );
  }
}
