import 'package:flutter/material.dart';

import '../models/coach_models.dart';
import '../theme/app_theme.dart';
import 'ui/fb_widgets.dart';

class AiCoachCard extends StatelessWidget {
  const AiCoachCard({
    super.key,
    required this.message,
    required this.loading,
    required this.aiConfigured,
    required this.onRefresh,
  });

  final CoachMessage? message;
  final bool loading;
  final bool aiConfigured;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return FbCard(
      title: 'Совет Plime',
      icon: Icons.auto_awesome_outlined,
      iconColor: AppColors.october,
      trailing: IconButton(
        icon: const Icon(Icons.refresh_rounded, size: 20),
        onPressed: loading ? null : onRefresh,
        tooltip: 'Обновить совет',
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (message != null)
            Text(
              message!.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            )
          else
            Text(
              'Отметьте смены — появятся персональные советы.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FbBadge(
                label: message?.isAi == true ? 'ИИ' : 'Офлайн',
                color: message?.isAi == true ? AppColors.primary : AppColors.mint,
                small: true,
              ),
              if (!aiConfigured)
                const FbBadge(
                  label: 'ИИ не настроен',
                  color: AppColors.rose,
                  small: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
