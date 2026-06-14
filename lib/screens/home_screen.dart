import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/goal_provider.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';
import '../services/badge_service.dart';
import '../services/balance_service.dart';
import '../services/motivation_service.dart';
import '../widgets/balance_ring_chart.dart';
import '../widgets/day_editor_panel.dart';
import '../widgets/goal_settings_panel.dart';
import '../widgets/goal_analogies_card.dart';
import '../widgets/keyboard_toolbar.dart';
import '../widgets/milestone_badges_row.dart';
import '../widgets/month_calendar.dart';
import '../widgets/progress_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/weekly_challenges_card.dart';
import '../widgets/ui/fb_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = GoalCalculator.dateOnly(DateTime.now());
  bool _settingsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        final calculator = provider.calculator;
        final stats = calculator.totalStats;
        final numberFormat = NumberFormat.decimalPattern('ru');
        final progress = calculator.settings.targetAmount > 0
            ? (stats.totalAmount / calculator.settings.targetAmount)
                .clamp(0.0, 1.0)
            : 0.0;
        final balance = BalanceService().compute(calculator);
        final badges = BadgeService().badges(calculator);
        final motivation = MotivationService();
        final shiftStreak = motivation.shiftStreak(calculator);
        final planStreak = motivation.planStreak(calculator);
        final challenges = motivation.weeklyChallenges(calculator);
        final analogies = motivation.goalAnalogies(calculator);
        final selectedEntry = calculator.getDayData(_selectedDate);
        final unlockedBadges =
            badges.where((b) => b.unlocked).length.toString();

        return DismissKeyboard(
          child: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => provider.init(),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  FbAppHeader(
                    pageTitle: 'Сегодня',
                    isDark: provider.isDarkMode,
                    onToggleTheme: provider.toggleDarkMode,
                    badge: '$unlockedBadges наград',
                  ),
                  const SizedBox(height: 16),
                  MonthCalendar(
                    calculator: calculator,
                    selectedDate: _selectedDate,
                    onDateSelected: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                  const SizedBox(height: 12),
                  DayEditorPanel(
                    key: ValueKey(
                      '${GoalCalculator.dateToKey(_selectedDate)}_'
                      '${selectedEntry.hours}_${selectedEntry.amount}_'
                      '${selectedEntry.notes}',
                    ),
                    date: _selectedDate,
                    entry: selectedEntry,
                    onSave: (entry) =>
                        provider.setDayData(_selectedDate, entry),
                    onClear: () => provider.clearDay(_selectedDate),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        label: 'Заработано',
                        value:
                            '${numberFormat.format(stats.totalAmount.floor())}₽',
                        accent: AppColors.mint,
                        icon: Icons.payments_outlined,
                      ),
                      StatCard(
                        label: 'До цели',
                        value:
                            '${numberFormat.format(calculator.remainingTarget.floor())}₽',
                        accent: AppColors.purple,
                        icon: Icons.flag_outlined,
                      ),
                      StatCard(
                        label: 'Часов',
                        value: stats.totalHours.toStringAsFixed(1),
                        accent: AppColors.primary,
                        icon: Icons.schedule_outlined,
                      ),
                      StatCard(
                        label: 'Ставка',
                        value: '${stats.avgRate.toStringAsFixed(0)} ₽/ч',
                        accent: AppColors.mintDark,
                        icon: Icons.trending_up_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _GoalHero(
                    title: provider.settings.title,
                    progress: progress,
                    earned: stats.totalAmount,
                    target: calculator.settings.targetAmount,
                    remaining: calculator.remainingTarget,
                  ),
                  const SizedBox(height: 12),
                  StreakCard(
                    shiftStreak: shiftStreak,
                    planStreak: planStreak,
                  ),
                  const SizedBox(height: 12),
                  WeeklyChallengesCard(challenges: challenges),
                  const SizedBox(height: 12),
                  GoalAnalogiesCard(analogies: analogies),
                  const SizedBox(height: 12),
                  MilestoneBadgesRow(badges: badges),
                  const SizedBox(height: 12),
                  FbCard(
                    title: 'Баланс цели',
                    icon: Icons.donut_large_outlined,
                    iconColor: AppColors.blue,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: BalanceRingChart(
                      segments: balance.segments,
                      centerValue:
                          '${balance.overallPercent.toStringAsFixed(0)}%',
                      centerLabel: 'общий баланс',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FbAlert(
                    message: calculator.generateAdvice(),
                    icon: Icons.lightbulb_outline_rounded,
                    color: AppColors.mint,
                  ),
                  const SizedBox(height: 12),
                  ProgressSection(calculator: calculator),
                  const SizedBox(height: 12),
                  _SettingsExpansion(
                    expanded: _settingsExpanded,
                    onToggle: () =>
                        setState(() => _settingsExpanded = !_settingsExpanded),
                    child: GoalSettingsPanel(
                      settings: provider.settings,
                      calculator: calculator,
                      onChanged: provider.updateSettings,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _confirmClearAll(context, provider),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Сбросить'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: () => _exportCsv(calculator),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Экспорт'),
                      ),
                    ],
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
        'plime_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
    await Share.share(csv, subject: fileName);
  }
}

class _GoalHero extends StatelessWidget {
  const _GoalHero({
    required this.title,
    required this.progress,
    required this.earned,
    required this.target,
    required this.remaining,
  });

  final String title;
  final double progress;
  final double earned;
  final double target;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('ru');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.heroGradient(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FbBadge(
                label: '${(progress * 100).toStringAsFixed(0)}%',
                color: AppColors.mint,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppDecorations.isDark(context)
                  ? AppColors.darkProgressBg
                  : AppColors.lightProgressBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.mint),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _heroStat(
                context,
                label: 'Заработано',
                value: '${numberFormat.format(earned.floor())}₽',
                color: AppColors.mint,
              ),
              _heroStat(
                context,
                label: 'Цель',
                value: '${numberFormat.format(target.floor())}₽',
                color: AppColors.primary,
              ),
            ],
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 10),
            Text(
              'Осталось ${numberFormat.format(remaining.floor())}₽',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroStat(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SettingsExpansion extends StatelessWidget {
  const _SettingsExpansion({
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(context),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
            title: const Text('Настройки цели'),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onToggle,
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ],
        ],
      ),
    );
  }
}
