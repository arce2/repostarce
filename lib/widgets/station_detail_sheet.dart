import 'package:flutter/material.dart';

import '../l10n/error_x.dart';
import '../l10n/l10n_x.dart';
import '../models/fuel_type.dart';
import '../models/gas_station.dart';
import '../services/favorites_service.dart';
import '../services/fuel_price_service.dart';
import '../theme/app_theme.dart';

/// Litros que se asumen para calcular el ahorro en euros de ir a una
/// gasolinera más barata (depósito medio de un turismo).
const _assumedTankLiters = 50;

/// Hoja inferior con el detalle de una gasolinera: todos los combustibles
/// que vende, dirección, horario y el botón para empezar a navegar.
class StationDetailSheet extends StatefulWidget {
  const StationDetailSheet({
    super.key,
    required this.station,
    required this.highlightedFuel,
    required this.fuelService,
    required this.onNavigate,
    required this.onViewStation,
  });

  final GasStation station;
  final FuelType highlightedFuel;

  /// Se reutiliza el servicio ya usado por la pantalla que abrió esta
  /// ficha (en vez de crear uno nuevo) para no tener que volver a
  /// descargar las ~11.000 gasolineras solo para comparar precios cercanos.
  final FuelPriceService fuelService;

  /// Se llama al pulsar "Navegar hasta aquí". Puede tardar (pide la
  /// ubicación GPS actual y calcula la ruta), así que el propio widget
  /// muestra un spinner mientras se resuelve.
  final Future<void> Function() onNavigate;

  /// Se llama al tocar la gasolinera más barata sugerida en el aviso de
  /// ahorro: cierra esta ficha y abre la suya, para ver sus precios o
  /// navegar hasta ella.
  final void Function(GasStation station) onViewStation;

  @override
  State<StationDetailSheet> createState() => _StationDetailSheetState();
}

class _StationDetailSheetState extends State<StationDetailSheet> {
  final _favoritesService = FavoritesService();
  bool _navigating = false;
  bool _isFavorite = false;
  String? _error;

  GasStation? _cheaperNearby;
  double? _savings;

  @override
  void initState() {
    super.initState();
    _favoritesService.isFavorite(widget.station.id).then((value) {
      if (mounted) setState(() => _isFavorite = value);
    });
    _loadCheaperNearby();
  }

  /// Busca, entre las gasolineras cercanas (15 km) que venden el mismo
  /// combustible destacado, si hay alguna más barata que esta, y calcula
  /// cuánto se ahorraría llenando un depósito de [_assumedTankLiters] L.
  Future<void> _loadCheaperNearby() async {
    final myPrice = widget.station.priceFor(widget.highlightedFuel);
    if (myPrice == null) return;
    // findNearby recalcula y sobrescribe GasStation.distanceKm en todas las
    // estaciones cercanas (incluida esta misma, a 0 km) como efecto
    // secundario de su uso habitual en la búsqueda por GPS. Aquí solo lo
    // usamos para comparar precios, así que restauramos el valor original
    // para no "ensuciar" la distancia de una ficha abierta sin GPS.
    final originalDistance = widget.station.distanceKm;
    try {
      final nearby = await widget.fuelService.findNearby(
        lat: widget.station.latitude,
        lng: widget.station.longitude,
        initialRadiusKm: 15,
        minResults: 1,
        maxRadiusKm: 15,
      );
      widget.station.distanceKm = originalDistance;
      final others =
          nearby.where((s) => s.id != widget.station.id).toList();
      final cheaper =
          widget.fuelService.sortedByPrice(others, widget.highlightedFuel);
      if (cheaper.isEmpty || !mounted) return;
      final best = cheaper.first;
      final bestPrice = best.priceFor(widget.highlightedFuel);
      if (bestPrice != null && bestPrice < myPrice - 0.001) {
        setState(() {
          _cheaperNearby = best;
          _savings = (myPrice - bestPrice) * _assumedTankLiters;
        });
      }
    } catch (_) {
      // Sin conexión o fallo puntual: simplemente no mostramos la
      // comparación esta vez.
    }
  }

  Future<void> _toggleFavorite() async {
    final nowFavorite = await _favoritesService.toggleFavorite(widget.station.id);
    if (mounted) setState(() => _isFavorite = nowFavorite);
  }

  Future<void> _handleNavigate() async {
    setState(() {
      _navigating = true;
      _error = null;
    });
    try {
      await widget.onNavigate();
    } catch (e) {
      if (mounted) {
        setState(() => _error = localizedErrorMessage(e, context.l10n));
      }
    } finally {
      if (mounted) setState(() => _navigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final station = widget.station;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_gas_station_rounded,
                      color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.brand.isNotEmpty
                            ? station.brand
                            : l10n.commonGasStationFallback,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      Text(
                        [station.address, station.municipality, station.province]
                            .where((s) => s.isNotEmpty)
                            .join(', '),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite
                      ? l10n.stationRemoveFavoriteTooltip
                      : l10n.stationSaveFavoriteTooltip,
                  icon: Icon(
                    _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _isFavorite
                        ? AppTheme.cheapestColor
                        : colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (station.schedule.isNotEmpty)
                  _InfoChip(icon: Icons.access_time_rounded, label: station.schedule),
                if (station.distanceKm != null)
                  _InfoChip(
                    icon: Icons.social_distance_rounded,
                    label: '${station.distanceKm!.toStringAsFixed(1)} km',
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: station.availableFuelTypes.map((type) {
                  final highlighted = type == widget.highlightedFuel;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: highlighted
                          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.labelFor(l10n),
                            style: TextStyle(
                              fontWeight:
                                  highlighted ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${station.priceFor(type)!.toStringAsFixed(3)} €',
                          style: TextStyle(
                            fontWeight:
                                highlighted ? FontWeight.w800 : FontWeight.w600,
                            fontSize: highlighted ? 16 : 14,
                            color: highlighted
                                ? AppTheme.cheapestColor
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_cheaperNearby != null && _savings != null) ...[
              const SizedBox(height: 14),
              Material(
                color: AppTheme.cheapestColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    final cheaper = _cheaperNearby!;
                    Navigator.of(context).pop();
                    widget.onViewStation(cheaper);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.cheapestColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.savings_rounded,
                            color: AppTheme.cheapestColor, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.stationCheaperNearby(
                              _cheaperNearby!.brand.isNotEmpty
                                  ? _cheaperNearby!.brand
                                  : l10n.commonGasStationFallback,
                              _savings!.toStringAsFixed(2),
                              _assumedTankLiters,
                            ),
                            style: TextStyle(
                                fontSize: 12.5, color: colorScheme.onSurface),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.cheapestColor, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _navigating ? null : _handleNavigate,
              icon: _navigating
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.navigation_rounded),
              label: Text(_navigating
                  ? l10n.stationCalculatingRoute
                  : l10n.stationNavigateButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
