import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Guarda la velocidad media (km/h) de cada trayecto de navegación
/// completado, para poder dar recomendaciones de conducción eficiente.
/// Solo se registra al llegar al destino, a partir de las muestras del GPS
/// recibidas durante el trayecto — no es la velocidad "teórica" de la ruta,
/// sino la que realmente llevó el usuario.
class TripLogService {
  static const _prefsKey = 'trip_speed_log_v1';
  static const _maxEntries = 30;

  Future<List<double>> _readAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => (e as num).toDouble()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> recordTripAverageSpeedKmh(double speedKmh) async {
    if (speedKmh.isNaN || speedKmh <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final all = await _readAll(prefs);
    all.add(speedKmh);
    final trimmed =
        all.length > _maxEntries ? all.sublist(all.length - _maxEntries) : all;
    await prefs.setString(_prefsKey, jsonEncode(trimmed));
  }

  Future<List<double>> getRecentTripSpeeds() async {
    final prefs = await SharedPreferences.getInstance();
    return _readAll(prefs);
  }

  Future<double?> averageRecentSpeedKmh({int recentCount = 5}) async {
    final all = await getRecentTripSpeeds();
    if (all.isEmpty) return null;
    final recent = all.length > recentCount
        ? all.sublist(all.length - recentCount)
        : all;
    return recent.reduce((a, b) => a + b) / recent.length;
  }
}
