import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/goal_provider.dart';
import '../widgets/keyboard_toolbar.dart';
import 'focus_timer_screen.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    final tab = Uri.base.queryParameters['tab'];
    _index = switch (tab) {
      'stats' || '1' => 1,
      'focus' || '2' => 2,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return KeyboardToolbarOverlay(
          child: Scaffold(
            body: IndexedStack(
              index: _index,
              children: const [
                HomeScreen(),
                StatisticsScreen(),
                FocusTimerScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today),
                  label: 'Сегодня',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Статистика',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  selectedIcon: Icon(Icons.timer),
                  label: 'Фокус',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
