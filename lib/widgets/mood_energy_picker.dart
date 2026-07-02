import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MoodEnergyPicker extends StatelessWidget {
  const MoodEnergyPicker({
    super.key,
    required this.mood,
    required this.energy,
    required this.onMoodChanged,
    required this.onEnergyChanged,
  });

  final int? mood;
  final int? energy;
  final ValueChanged<int?> onMoodChanged;
  final ValueChanged<int?> onEnergyChanged;

  static const _labels = ['', '😞', '😕', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(
          context,
          title: 'Настроение',
          value: mood,
          onChanged: onMoodChanged,
          activeColor: AppColors.purple,
        ),
        const SizedBox(height: 10),
        _row(
          context,
          title: 'Энергия',
          value: energy,
          onChanged: onEnergyChanged,
          activeColor: AppColors.mint,
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context, {
    required String title,
    required int? value,
    required ValueChanged<int?> onChanged,
    required Color activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final level = i + 1;
            final selected = value == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
                child: Material(
                  color: selected
                      ? activeColor.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onChanged(selected ? null : level),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            _labels[level],
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            '$level',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w400,
                              color: selected ? activeColor : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
