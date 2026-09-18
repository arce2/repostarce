import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_log_entry.dart';

/// Guarda en el dispositivo el diario de repostajes del usuario (fecha,
/// litros, coste y, si se apunta, el kilometraje), para poder calcular el
/// gasto mensual y el consumo medio sin necesidad de ningún servidor.
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
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.add(entry);
    await prefs.setString(
      _prefsKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await prefs.setString(
      _prefsKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  /// Suma el coste de los repostajes hechos en el mes/año de [reference].
  double totalSpentInMonth(List<FuelLogEntry> entries, DateTime reference) {
    return entries
        .where((e) =>
            e.date.year == reference.year && e.date.month == reference.month)
        .fold(0.0, (sum, e) => sum + e.totalCost);
  }

  /// Consumo medio en L/100km, calculado entre repostajes consecutivos con
  /// el depósito lleno y kilometraje apuntado. Devuelve `null` si no hay
  /// datos suficientes todavía para calcularlo.
  double? averageConsumptionL100km(List<FuelLogEntry> entries) {
    final usable = entries.where((e) => e.fullTank && e.odometerKm != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (usable.length < 2) return null;

    final ratios = <double>[];
    for (var i = 1; i < usable.length; i++) {
      final distance = usable[i].odometerKm! - usable[i - 1].odometerKm!;
      if (distance <= 0) continue;
      ratios.add(usable[i].liters / distance * 100);
    }
    if (ratios.isEmpty) return null;
    return ratios.reduce((a, b) => a + b) / ratios.length;
  }
}
