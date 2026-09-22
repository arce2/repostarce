import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idiomas que el usuario puede elegir a mano en Ajustes, además de "seguir
/// el idioma del sistema" (representado como [locale] `null`).
const supportedAppLocales = [Locale('es'), Locale('en'), Locale('fr')];

/// Guarda y expone el idioma elegido por el usuario (o `null` para seguir
/// el idioma del sistema), persistido entre sesiones.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      _locale = supportedAppLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => supportedAppLocales.first,
      );
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
