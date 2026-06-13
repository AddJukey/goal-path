import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/goal_provider.dart';
import '../services/goal_calculator.dart';
import '../theme/app_theme.dart';
import '../models/balance_segment.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = GoalCalculator.dateOnly(DateTime.now());

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

        return DismissKeyboard(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => provider.init(),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _Header(
                    title: provider.settings.title,
                    isDark: provider.isDarkMode,
                    onToggleTheme: provider.toggleDarkMode,
                  ),
                  const SizedBox(height: 12),
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
                _GoalHero(
                  title: provider.settings.title,
                  progress: progress,
                  earned: stats.totalAmount,
                  target: calculator.settings.targetAmount,
                  remaining: calculator.remainingTarget,
                ),
                const SizedBox(height: 16),
                StreakCard(
                  shiftStreak: shiftStreak,
                  planStreak: planStreak,
                ),
                const SizedBox(height: 12),
                WeeklyChallengesCard(challenges: challenges),
                const SizedBox(height: 12),
                GoalAnalogiesCard(analogies: analogies),
                const SizedBox(height: 16),
                _BalanceCard(balance: balance),
                const SizedBox(height: 16),
                MilestoneBadgesRow(badges: badges),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.55,
                  children: [
                    StatCard(
                      label: 'Заработано',
                      value:
                          '${numberFormat.format(stats.totalAmount.floor())}₽',
                      accent: AppColors.mint,
                    ),
                    StatCard(
                      label: 'До цели',
                      value:
                          '${numberFormat.format(calculator.remainingTarget.floor())}₽',
                      accent: AppColors.purple,
                    ),
                    StatCard(
                      label: 'Часов',
                      value: stats.totalHours.toStringAsFixed(1),
                      accent: AppColors.blue,
                    ),
                    StatCard(
                      label: 'Ставка',
                      value: '${stats.avgRate.toStringAsFixed(0)} ₽/ч',
                      accent: AppColors.mintDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GoalSettingsPanel(
                  settings: provider.settings,
                  calculator: calculator,
                  onChanged: provider.updateSettings,
                ),
                const SizedBox(height: 16),
                ProgressSection(calculator: calculator),
                const SizedBox(height: 16),
                _AdviceCard(text: calculator.generateAdvice()),
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
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: const Color(0xFF0A0A0F),
                      ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.mint, AppColors.blue],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'plime',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF0A0A0F),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Сегодня',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                ),
          ),
        ),
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        ),
      ],
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberFormat = NumberFormat.decimalPattern('ru');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A2E2A), const Color(0xFF16161F)]
              : [const Color(0xFFE0FDF8), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.mint.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.darkProgressBg
                  : AppColors.lightProgressBg,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.mint),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${numberFormat.format(earned.floor())}₽',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.mint,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${numberFormat.format(target.floor())}₽',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Осталось ${numberFormat.format(remaining.floor())}₽',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final GoalBalance balance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Баланс цели',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 16),
          BalanceRingChart(
            segments: balance.segments,
            centerValue: '${balance.overallPercent.toStringAsFixed(0)}%',
            centerLabel: 'общий баланс',
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.mint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
