import '../l10n/gen/app_localizations.dart';
import '../models/fuel_log_entry.dart';
import 'fuel_log_service.dart';
import 'trip_log_service.dart';

/// Umbrales usados para decidir qué recomendaciones mostrar. Son reglas
/// fijas (sin llamar a ningún servicio de IA externo), pensadas para ser
/// prudentes: solo avisan cuando el cambio es lo bastante grande como para
/// no ser ruido de un solo repostaje o trayecto.
class RecommendationThresholds {
  static const consumptionRisePercent = 8.0;
  static const consumptionImprovePercent = -8.0;
  static const highSpeedKmh = 110.0;
  static const lowSpeedKmh = 30.0;
  static const highConsumptionL100km = 7.0;
}

/// Genera consejos personalizados a partir del historial de repostajes
/// (consumo medio y su tendencia) y de la velocidad media de los trayectos
/// navegados recientes.
class RecommendationService {
  final _fuelLogService = FuelLogService();
  final _tripLogService = TripLogService();

  Future<List<String>> buildRecommendations(AppLocalizations l10n) async {
    final entries = await _fuelLogService.getEntries();
    final avgSpeed = await _tripLogService.averageRecentSpeedKmh();
    return _evaluate(l10n, entries, avgSpeed);
  }

  List<String> _evaluate(
    AppLocalizations l10n,
    List<FuelLogEntry> entries,
    double? avgSpeedKmh,
  ) {
    final trendPercent = _fuelLogService.consumptionTrendPercent(entries);
    final avgConsumption = _fuelLogService.averageConsumption(entries);

    final hasEnoughData = trendPercent != null || avgSpeedKmh != null;
    if (!hasEnoughData) return [];

    final tips = <String>[];

    if (trendPercent != null &&
        trendPercent >= RecommendationThresholds.consumptionRisePercent) {
      tips.add(l10n.recoConsumptionRising(trendPercent.toStringAsFixed(0)));
    } else if (trendPercent != null &&
        trendPercent <= RecommendationThresholds.consumptionImprovePercent) {
      tips.add(l10n
          .recoConsumptionImproving(trendPercent.abs().toStringAsFixed(0)));
    }

    if (avgSpeedKmh != null &&
        avgSpeedKmh >= RecommendationThresholds.highSpeedKmh) {
      tips.add(l10n.recoHighSpeed(avgSpeedKmh.toStringAsFixed(0)));
    } else if (avgSpeedKmh != null &&
        avgSpeedKmh <= RecommendationThresholds.lowSpeedKmh &&
        avgConsumption != null &&
        avgConsumption >= RecommendationThresholds.highConsumptionL100km) {
      tips.add(l10n.recoLowSpeedHighConsumption(avgSpeedKmh.toStringAsFixed(0)));
    }

    if (tips.isEmpty) tips.add(l10n.recoAllGood);
    return tips;
  }
}
