import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/goal_provider.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/day_list.dart';
import '../widgets/goal_settings_panel.dart';
import '../widgets/progress_section.dart';
import '../widgets/quick_add_panel.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final calculator = provider.calculator;
        final stats = calculator.totalStats;
        final numberFormat = NumberFormat.decimalPattern('ru');

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => provider.init(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Header(
                    title: provider.settings.title,
                    isDark: provider.isDarkMode,
                    onToggleTheme: provider.toggleDarkMode,
                  ),
                  const SizedBox(height: 16),
                  GoalSettingsPanel(
                    settings: provider.settings,
                    calculator: calculator,
                    onChanged: provider.updateSettings,
                  ),
                  const SizedBox(height: 16),
                  QuickAddPanel(onAdd: provider.addShiftToday),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      StatCard(
                        label: '💰 ВСЕГО ЗАРАБОТАНО',
                        value: '${numberFormat.format(stats.totalAmount.floor())}₽',
                      ),
                      StatCard(
                        label: '🎯 ОСТАЛОСЬ ДО ЦЕЛИ',
                        value:
                            '${numberFormat.format(calculator.remainingTarget.floor())}₽',
                      ),
                      StatCard(
                        label: '⏱️ ВСЕГО ЧАСОВ',
                        value: stats.totalHours.toStringAsFixed(1),
                      ),
                      StatCard(
                        label: '💰 СРЕДНЯЯ СТАВКА',
                        value: '${stats.avgRate.toStringAsFixed(0)} ₽/ч',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ProgressSection(calculator: calculator),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 Совет дня',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Text(
                              calculator.generateAdvice(),
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF1E2A3E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DayList(
                    calculator: calculator,
                    onDayChanged: (date, entry) =>
                        provider.setDayData(date, entry),
                    onDayCleared: provider.clearDay,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _confirmClearAll(context, provider),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Сбросить'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => _exportCsv(calculator),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: const Color(0xFF1E2A3E),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text('Экспорт CSV'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Вводи часы и сумму за каждый день. Прогнозы используют твою реальную эффективность.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    GoalProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить все данные?'),
        content: const Text('Это действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearAll();
    }
  }

  Future<void> _exportCsv(GoalCalculator calculator) async {
    final csv = calculator.buildCsv();
    final fileName =
        'goal_path_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
    await Share.share(csv, subject: fileName);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.isDark,
    required this.onToggleTheme,
  });

  final String title;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '🎯 $title',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        ),
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
        ),
      ],
    );
  }
}
