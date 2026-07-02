import 'package:flutter/material.dart';

import '../models/app_preferences.dart';
import '../services/cloudflare_ai_service.dart';
import '../theme/app_theme.dart';

class CoachSettingsPanel extends StatelessWidget {
  const CoachSettingsPanel({
    super.key,
    required this.prefs,
    required this.onChanged,
  });

  final AppPreferences prefs;
  final ValueChanged<AppPreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    final aiConfigured = CloudflareAiService().isConfigured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Plime Coach',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Умные советы (интернет)'),
          subtitle: Text(
            aiConfigured
                ? 'ИИ через Cloudflare Workers'
                : 'URL не задан — только офлайн-советы',
          ),
          value: prefs.smartCoachEnabled,
          onChanged: (v) => onChanged(prefs.copyWith(smartCoachEnabled: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Только офлайн-советы'),
          subtitle: const Text('Без запросов к ИИ, быстрые заготовки'),
          value: prefs.offlineCoachOnly,
          onChanged: (v) => onChanged(prefs.copyWith(offlineCoachOnly: v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Офлайн-микс: ${prefs.scriptedMixPercent}%'),
          subtitle: Slider(
            value: prefs.scriptedMixPercent.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            label: '${prefs.scriptedMixPercent}%',
            onChanged: prefs.offlineCoachOnly || !prefs.smartCoachEnabled
                ? null
                : (v) => onChanged(
                      prefs.copyWith(scriptedMixPercent: v.round()),
                    ),
          ),
        ),
        const Divider(),
        Text('Таймер фокуса', style: Theme.of(context).textTheme.titleSmall),
        Row(
          children: [
            Expanded(
              child: _minuteField(
                context,
                label: 'Фокус (мин)',
                value: prefs.focusMinutes,
                onChanged: (v) => onChanged(prefs.copyWith(focusMinutes: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _minuteField(
                context,
                label: 'Перерыв (мин)',
                value: prefs.breakMinutes,
                onChanged: (v) => onChanged(prefs.copyWith(breakMinutes: v)),
              ),
            ),
          ],
        ),
        if (!aiConfigured) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.octoberLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Чтобы включить ИИ: разверните Worker из папки cloudflare/ '
              'и соберите APK с --dart-define=AI_WORKER_URL=https://.... '
              'Инструкция: cloudflare/README.md',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _minuteField(
    BuildContext context, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: const [15, 20, 25, 30, 45, 50]
          .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
