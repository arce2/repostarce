import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Punto que marca la posición del usuario en el mapa (azul, como en la
/// mayoría de apps de navegación, para distinguirlo claramente de las
/// gasolineras), con un anillo tipo "radar" que pulsa hacia fuera para dar
/// sensación de posición en vivo. La animación es puramente decorativa
/// (un solo AnimationController, sin rebuilds del resto del mapa), así que
/// no afecta al rendimiento de la navegación.
class UserLocationDot extends StatefulWidget {
  const UserLocationDot({super.key, this.color = const Color(0xFF2E6ADE)});

  final Color color;

  @override
  State<UserLocationDot> createState() => _UserLocationDotState();
}

class _UserLocationDotState extends State<UserLocationDot>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Opacity(
              opacity: (1 - t).clamp(0.0, 1.0) * 0.5,
              child: Transform.scale(
                scale: 0.4 + t * 1.1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.35),
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
            ],
          ),
        ),
      ],
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
