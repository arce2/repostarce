import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/gen/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/locale_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FuelFinderApp());
}

class FuelFinderApp extends StatefulWidget {
  const FuelFinderApp({super.key});

  @override
  State<FuelFinderApp> createState() => _FuelFinderAppState();
}

class _FuelFinderAppState extends State<FuelFinderApp> {
  final _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _localeController.addListener(_onLocaleChanged);
    _localeController.load();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  void dispose() {
    _localeController.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: _localeController.locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(localeController: _localeController),
    );
  }
}
