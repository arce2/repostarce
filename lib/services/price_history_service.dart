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

  /// Registra el precio de hoy para esta gasolinera+combustible (si no se
  /// había guardado ya hoy) y devuelve el precio del día distinto más
  /// reciente anterior, o `null` si no hay histórico previo con el que
  /// comparar.
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

    final double? previous;
    if (alreadyToday) {
      previous = history.length > 1
          ? (history[history.length - 2]['p'] as num).toDouble()
          : null;
    } else {
      previous =
          history.isNotEmpty ? (history.last['p'] as num).toDouble() : null;
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
