import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_log_entry.dart';
import '../models/fuel_type.dart';

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

  List<FuelLogEntry> entriesInMonth(List<FuelLogEntry> entries, DateTime month) =>
      entries
          .where((e) => e.date.year == month.year && e.date.month == month.month)
          .toList();

  double totalSpentInMonth(List<FuelLogEntry> entries, DateTime month) =>
      totalSpent(entriesInMonth(entries, month));

  DateTime? lastFillUpDate(List<FuelLogEntry> entries) => entries.isEmpty
      ? null
      : entries.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);

  /// Estima en cuántos días tocará el próximo repostaje de este vehículo,
  /// a partir de dos datos reales: cuántos km da de media un depósito (la
  /// autonomía real del coche, no un dato genérico) y a qué ritmo se está
  /// recorriendo distancia de verdad (km/día desde el primer repostaje con
  /// km hasta el último). No es solo la media de días entre repostajes
  /// pasados: si el coche se usa más o menos que antes, el ritmo real de
  /// km/día ya lo recoge. `null` con menos de 2 repostajes con km
  /// registrados, o si no hay margen de tiempo suficiente para medir ritmo.
  double? estimatedDaysUntilNextFillUp(List<FuelLogEntry> entries) {
    final withKm = entries.where((e) => e.kmSinceLast > 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (withKm.length < 2) return null;

    final totalKm = withKm.fold(0.0, (sum, e) => sum + e.kmSinceLast);
    final avgKmPerTank = totalKm / withKm.length;

    final totalDays =
        withKm.last.date.difference(withKm.first.date).inHours / 24.0;
    if (totalDays <= 0) return null;
    final avgKmPerDay = totalKm / totalDays;
    if (avgKmPerDay <= 0) return null;

    return avgKmPerTank / avgKmPerDay;
  }

  /// Cuánto se ha ahorrado (o perdido) este mes frente al precio medio
  /// nacional de cada combustible, a partir de lo que de verdad se pagó en
  /// cada repostaje. `null` si no hay repostajes este mes o no hay datos de
  /// precio medio con los que comparar.
  double? estimatedSavingsInMonth(
    List<FuelLogEntry> monthEntries,
    Map<FuelType, double> nationalAveragePrices,
  ) {
    if (monthEntries.isEmpty || nationalAveragePrices.isEmpty) return null;
    var total = 0.0;
    var any = false;
    for (final entry in monthEntries) {
      final avg = nationalAveragePrices[entry.fuelType];
      if (avg == null || entry.liters <= 0) continue;
      any = true;
      total += (avg - entry.pricePerLiter) * entry.liters;
    }
    return any ? total : null;
  }
}
