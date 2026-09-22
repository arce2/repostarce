import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_log_entry.dart';

/// Guarda en el dispositivo el historial de repostajes que el usuario
/// registra a mano, para llevar el gasto y calcular el consumo medio.
class FuelLogService {
  static const _prefsKey = 'fuel_log_v1';

  Future<List<FuelLogEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final entries = list
          .cast<Map<String, dynamic>>()
          .map(FuelLogEntry.fromJson)
          .toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(FuelLogEntry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    await _save(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await _save(entries);
  }

  Future<void> _save(List<FuelLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  double totalSpent(List<FuelLogEntry> entries) =>
      entries.fold(0, (sum, e) => sum + e.totalPrice);

  /// Consumo medio (L/100km) de los repostajes con km declarados,
  /// ponderado por litros para no dejar que un repostaje pequeño pese lo
  /// mismo que uno grande.
  double? averageConsumption(List<FuelLogEntry> entries) {
    final withKm = entries.where((e) => e.kmSinceLast > 0).toList();
    if (withKm.isEmpty) return null;
    final totalLiters = withKm.fold(0.0, (sum, e) => sum + e.liters);
    final totalKm = withKm.fold(0.0, (sum, e) => sum + e.kmSinceLast);
    if (totalKm == 0) return null;
    return (totalLiters / totalKm) * 100;
  }

  /// Compara el consumo medio de los últimos [recentCount] repostajes con
  /// el de los anteriores a esos, como variación porcentual (positivo =
  /// ha subido el consumo). `null` si no hay suficiente historial para
  /// comparar.
  double? consumptionTrendPercent(List<FuelLogEntry> entries,
      {int recentCount = 3}) {
    final withKm = entries.where((e) => e.kmSinceLast > 0).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (withKm.length < recentCount + 1) return null;

    final recent = withKm.take(recentCount).toList();
    final older = withKm.skip(recentCount).toList();

    final recentAvg = averageConsumption(recent);
    final olderAvg = averageConsumption(older);
    if (recentAvg == null || olderAvg == null || olderAvg == 0) return null;

    return ((recentAvg - olderAvg) / olderAvg) * 100;
  }
}
