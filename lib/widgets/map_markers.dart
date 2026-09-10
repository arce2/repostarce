import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Punto que marca la posición del usuario en el mapa (azul, como en la
/// mayoría de apps de navegación, para distinguirlo claramente de las
/// gasolineras).
class UserLocationDot extends StatelessWidget {
  const UserLocationDot({super.key, this.color = const Color(0xFF2E6ADE)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Marcador circular de gasolinera: ámbar y con estrella para la más
/// barata, rojo y con flecha para la más cara, verde de marca (o el color
/// que se indique) para el resto.
class StationMarker extends StatelessWidget {
  const StationMarker({
    super.key,
    this.isCheapest = false,
    this.isMostExpensive = false,
    this.onTap,
    this.color,
  });

  final bool isCheapest;
  final bool isMostExpensive;
  final VoidCallback? onTap;

  /// Color a usar cuando no es ni la más barata ni la más cara. Si es
  /// null, usa el color primario del tema.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedColor = isCheapest
        ? AppTheme.cheapestColor
        : isMostExpensive
            ? AppTheme.mostExpensiveColor
            : (color ?? colorScheme.primary);
    final icon = isCheapest
        ? Icons.star_rounded
        : isMostExpensive
            ? Icons.trending_up_rounded
            : Icons.local_gas_station_rounded;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: resolvedColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 3),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: FittedBox(child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}
