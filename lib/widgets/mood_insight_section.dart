import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coach_models.dart';
import '../providers/goal_provider.dart';
import '../services/coach_service.dart';
import '../services/mood_insights_service.dart';
import '../services/situation_detector.dart';
import 'mood_insight_card.dart';

class MoodInsightSection extends StatefulWidget {
  const MoodInsightSection({super.key});

  @override
  State<MoodInsightSection> createState() => _MoodInsightSectionState();
}

class _MoodInsightSectionState extends State<MoodInsightSection> {
  final _mood = MoodInsightsService();
  final _coach = CoachService();
  final _detector = SituationDetector();
  CoachMessage? _insight;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final provider = context.read<GoalProvider>();
    final correlation = _mood.analyze(provider.calculator);
    if (!correlation.hasData) {
      setState(() {
        _insight = null;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    final ctx = _detector.buildMoodInsight(
      provider.calculator,
      avgMoodHighEarn: correlation.avgHighMoodEarn,
      avgMoodLowEarn: correlation.avgLowMoodEarn,
      sampleDays: correlation.moodSampleDays,
    );
    final msg = await _coach.moodInsight(ctx, provider.appPreferences);
    if (mounted) {
      setState(() {
        _insight = msg;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final correlation =
        _mood.analyze(context.watch<GoalProvider>().calculator);
    return Column(
      children: [
        MoodInsightCard(
          correlation: correlation,
          insight: _insight,
          loading: _loading,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
