import 'package:flutter/material.dart';

import '../models/fuel_type.dart';
import '../models/gas_station.dart';
import '../theme/app_theme.dart';

/// Fila de la lista de resultados: marca, dirección, distancia y precio
/// del combustible elegido, marcando si es la más barata o la más cara.
class StationListTile extends StatelessWidget {
  const StationListTile({
    super.key,
    required this.station,
    required this.fuelType,
    required this.isCheapest,
    this.isMostExpensive = false,
    this.previousPrice,
    this.cardDiscountPerLiter,
    required this.onTap,
  });

  final GasStation station;
  final FuelType fuelType;
  final bool isCheapest;
  final bool isMostExpensive;

  /// Precio del día distinto más reciente que se tenga registrado, para
  /// mostrar si ha subido o bajado desde entonces. `null` si no hay
  /// histórico (p.ej. primera vez que se consulta esta gasolinera).
  final double? previousPrice;

  /// Cuánto descuenta por litro la tarjeta de fidelización del usuario
  /// para la marca de esta gasolinera, si tiene una. `null` si no aplica
  /// ninguna.
  final double? cardDiscountPerLiter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final price = station.priceFor(fuelType);
    final highlighted = isCheapest || isMostExpensive;
    final accent = isCheapest
        ? AppTheme.cheapestColor
        : isMostExpensive
            ? AppTheme.mostExpensiveColor
            : colorScheme.primary;
    final icon = isCheapest
        ? Icons.star_rounded
        : isMostExpensive
            ? Icons.trending_up_rounded
            : Icons.local_gas_station_rounded;
    final badgeLabel = isCheapest ? 'más barata' : 'más cara';
    final trendDelta =
        price != null && previousPrice != null ? price - previousPrice! : null;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? accent.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: highlighted ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            station.brand.isNotEmpty ? station.brand : 'Gasolinera',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (station.isOpen24h) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '24H',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        station.address,
                        station.municipality,
                        if (station.distanceKm != null)
                          '${station.distanceKm!.toStringAsFixed(1)} km',
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price != null ? '${price.toStringAsFixed(3)} €' : '—',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: highlighted ? accent : colorScheme.onSurface,
                    ),
                  ),
                  if (price != null && cardDiscountPerLiter != null)
                    Text(
                      'con tarjeta: '
                      '${(price - cardDiscountPerLiter! < 0 ? 0.0 : price - cardDiscountPerLiter!).toStringAsFixed(3)} €',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  if (trendDelta != null && trendDelta.abs() >= 0.001)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendDelta > 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: trendDelta > 0
                              ? AppTheme.mostExpensiveColor
                              : AppTheme.cheapestColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${trendDelta.abs().toStringAsFixed(3)} €',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: trendDelta > 0
                                ? AppTheme.mostExpensiveColor
                                : AppTheme.cheapestColor,
                          ),
                        ),
                      ],
                    ),
                  if (highlighted) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
