import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_type.dart';

/// Guarda en el dispositivo un histórico ligero (un precio por día, hasta
/// 30 días) de cada gasolinera+combustible que se haya consultado, para
/// poder mostrar si ha subido o bajado desde la última vez que se miró.
class PriceHistoryService {
  static const _prefsKey = 'price_history_v1';
  static const _maxEntriesPerKey = 30;

  String _keyFor(String stationId, FuelType type) => '$stationId|${type.name}';

  Future<Map<String, dynamic>> _readAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Registra el precio actual para esta gasolinera+combustible y devuelve
  /// el precio con el que se debe comparar (el último conocido antes de
  /// esta llamada), o `null` si no hay histórico previo.
  ///
  /// Si ya se había registrado un precio hoy pero ha cambiado desde
  /// entonces (p.ej. la gasolinera lo actualiza a media mañana y se vuelve
  /// a comprobar por la tarde), se actualiza el registro de hoy en vez de
  /// crear uno nuevo, para poder detectar cambios varias veces al día y no
  /// solo una vez por jornada.
  Future<double?> recordAndGetPrevious(
    String stationId,
    FuelType type,
    double currentPrice,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _readAll(prefs);
    final key = _keyFor(stationId, type);
    final history =
        ((all[key] as List<dynamic>?) ?? const []).cast<Map<String, dynamic>>();

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final alreadyToday = history.isNotEmpty && history.last['d'] == todayKey;
    final previous =
        history.isNotEmpty ? (history.last['p'] as num).toDouble() : null;

    if (alreadyToday) {
      if (previous != currentPrice) {
        final updated = [...history];
        updated[updated.length - 1] = {'d': todayKey, 'p': currentPrice};
        all[key] = updated;
        await prefs.setString(_prefsKey, jsonEncode(all));
      }
    } else {
      final updated = [...history, {'d': todayKey, 'p': currentPrice}];
      if (updated.length > _maxEntriesPerKey) {
        updated.removeAt(0);
      }
      all[key] = updated;
      await prefs.setString(_prefsKey, jsonEncode(all));
    }
    return previous;
  }
}
