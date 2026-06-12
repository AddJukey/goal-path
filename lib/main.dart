import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/goal_provider.dart';
import 'screens/shell_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GoalPathApp());
}

class GoalPathApp extends StatefulWidget {
  const GoalPathApp({super.key});

  @override
  State<GoalPathApp> createState() => _GoalPathAppState();
}

class _GoalPathAppState extends State<GoalPathApp> {
  late final Future<GoalProvider> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = _createProvider();
  }

  Future<GoalProvider> _createProvider() async {
    final provider = GoalProvider(StorageService());
    await provider.init();
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GoalProvider>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Ошибка запуска: ${snapshot.error}'),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return ChangeNotifierProvider.value(
          value: snapshot.data!,
          child: Consumer<GoalProvider>(
            builder: (context, provider, _) {
              return MaterialApp(
                title: 'Plime',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode:
                    provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                locale: const Locale('ru'),
                supportedLocales: const [Locale('ru')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const ShellScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
