import 'package:flutter/material.dart';

import '../models/coach_models.dart';
import '../services/mood_insights_service.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class MoodInsightCard extends StatelessWidget {
  const MoodInsightCard({
    super.key,
    required this.correlation,
    required this.insight,
    required this.loading,
  });

  final MoodCorrelation correlation;
  final CoachMessage? insight;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!correlation.hasData) {
      return FbCard(
        title: 'Настроение и заработок',
        icon: Icons.psychology_outlined,
        iconColor: AppColors.purple,
        child: Text(
          'Отмечайте настроение и энергию в сменах — появится анализ связи с доходом.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return FbCard(
      title: 'Настроение и заработок',
      icon: Icons.psychology_outlined,
      iconColor: AppColors.purple,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(context, 'Дней: ${correlation.moodSampleDays}'),
              const SizedBox(width: 8),
              if (correlation.avgEnergy != null)
                _chip(
                  context,
                  'Энергия: ${correlation.avgEnergy!.toStringAsFixed(1)}/5',
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const LinearProgressIndicator(minHeight: 2)
          else if (insight != null)
            Text(
              insight!.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            ),
          if (insight != null) ...[
            const SizedBox(height: 8),
            Text(
              insight!.isAi ? 'ИИ · анализ' : 'Офлайн · анализ',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.purple,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.purpleLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
