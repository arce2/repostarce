import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../config/api_keys.dart';
import '../l10n/error_x.dart';
import '../l10n/l10n_x.dart';
import '../models/gas_station.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import '../services/trip_log_service.dart';
import '../widgets/map_markers.dart';

/// Pantalla de navegación turn-by-turn hasta la gasolinera elegida:
/// dibuja la ruta, sigue la posición del usuario en vivo y va mostrando
/// la siguiente maniobra a medida que avanza.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    super.key,
    required this.origin,
    required this.station,
  });

  final LatLng origin;
  final GasStation station;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final _routingService = RoutingService();
  final _locationService = LocationService();
  final _tripLogService = TripLogService();
  final _mapController = MapController();

  static const _arrivalThresholdMeters = 30.0;
  static const _offRouteThresholdMeters = 70.0;

  RouteResult? _route;
  int _stepIndex = 0;
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSub;
  bool _loading = true;
  bool _arrived = false;
  bool _offRoute = false;
  String? _error;

  /// Velocidades (m/s) recibidas del GPS durante el trayecto, para calcular
  /// la velocidad media real al llegar y usarla en las recomendaciones de
  /// conducción eficiente.
  final List<double> _speedSamplesMs = [];
  bool _speedRecorded = false;

  late LatLng _destination;
  bool _initialLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _destination = LatLng(widget.station.latitude, widget.station.longitude);
    _currentPosition = widget.origin;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _loadRoute lee Localizations.localeOf(context), que no está
    // disponible todavía en initState(): se pide la ruta aquí, la primera
    // vez que las dependencias heredadas están listas.
    if (!_initialLoadStarted) {
      _initialLoadStarted = true;
      _loadRoute(widget.origin);
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _loadRoute(LatLng from) async {
    setState(() {
      _loading = true;
      _error = null;
      _offRoute = false;
    });
    try {
      final route = await _routingService.getRoute(
        origin: from,
        destination: _destination,
        languageCode: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      setState(() {
        _route = route;
        _stepIndex = 0;
        _loading = false;
      });
      _positionSub ??= _locationService.watchPosition().listen(_onPosition);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = localizedErrorMessage(e, context.l10n);
        _loading = false;
      });
    }
  }

  void _onPosition(Position position) {
    final current = LatLng(position.latitude, position.longitude);
    final route = _route;
    if (route == null) return;

    setState(() => _currentPosition = current);

    if (position.speed >= 0 && position.speed.isFinite) {
      _speedSamplesMs.add(position.speed);
    }

    final distanceToDestination = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      _destination.latitude,
      _destination.longitude,
    );
    if (distanceToDestination <= _arrivalThresholdMeters) {
      setState(() => _arrived = true);
      _recordTripSpeed();
      return;
    }

    // Avanza al siguiente paso si ya estamos cerca de la maniobra actual.
    if (_stepIndex < route.steps.length - 1) {
      final nextManeuver = route.steps[_stepIndex + 1].maneuverLocation;
      final distanceToManeuver = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        nextManeuver.latitude,
        nextManeuver.longitude,
      );
      if (distanceToManeuver <= _arrivalThresholdMeters) {
        setState(() => _stepIndex++);
      }
    }

    // Comprueba si nos hemos desviado bastante de la ruta trazada.
    final minDistanceToRoute = _distanceToPolyline(current, route.polyline);
    setState(() => _offRoute = minDistanceToRoute > _offRouteThresholdMeters);
  }

  /// Guarda la velocidad media real del trayecto (a partir de las muestras
  /// del GPS recibidas), una sola vez por trayecto, para las
  /// recomendaciones de conducción eficiente en "Consumo y gastos".
  void _recordTripSpeed() {
    if (_speedRecorded || _speedSamplesMs.isEmpty) return;
    _speedRecorded = true;
    final avgMs =
        _speedSamplesMs.reduce((a, b) => a + b) / _speedSamplesMs.length;
    _tripLogService.recordTripAverageSpeedKmh(avgMs * 3.6);
  }

  /// Distancia mínima (aprox., en metros) de un punto a una polilínea,
  /// comprobando la distancia a cada vértice. Suficiente para detectar
  /// que el usuario se ha salido claramente de la ruta.
  double _distanceToPolyline(LatLng point, List<LatLng> polyline) {
    var min = double.infinity;
    for (final vertex in polyline) {
      final d = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        vertex.latitude,
        vertex.longitude,
      );
      if (d < min) min = d;
    }
    return min;
  }

  double _angleForModifier(String modifier) {
    switch (modifier) {
      case 'straight':
        return 0;
      case 'slight right':
        return 30;
      case 'right':
        return 90;
      case 'sharp right':
        return 135;
      case 'uturn':
        return 180;
      case 'sharp left':
        return -135;
      case 'left':
        return -90;
      case 'slight left':
        return -30;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTitle(widget.station.brand.isNotEmpty
            ? widget.station.brand
            : l10n.navGasStationFallback)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.navRecalcTooltip,
            onPressed: _currentPosition == null
                ? null
                : () => _loadRoute(_currentPosition!),
          ),
          const SizedBox(width: 4),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _loadRoute(_currentPosition ?? widget.origin),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    final route = _route!;
    final step = route.steps[_stepIndex];
    final current = _currentPosition ?? widget.origin;
    final remainingToManeuver = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      step.maneuverLocation.latitude,
      step.maneuverLocation.longitude,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: current,
            initialZoom: 17,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${ApiKeys.mapTiler}',
              userAgentPackageName: 'com.fuelfinder.fuel_finder',
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('MapTiler'),
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
            PolylineLayer(polylines: [
              Polyline(
                points: route.polyline,
                strokeWidth: 6,
                color: colorScheme.primary,
              ),
            ]),
            MarkerLayer(markers: [
              Marker(
                point: current,
                width: 42,
                height: 42,
                child: const UserLocationDot(),
              ),
              Marker(
                point: _destination,
                width: 40,
                height: 40,
                child: const StationMarker(),
              ),
            ]),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: _InstructionCard(
            angle: _angleForModifier(step.maneuverModifier),
            distanceMeters: remainingToManeuver,
            instruction: step.instruction,
          ),
        ),
        if (_offRoute)
          Positioned(
            top: 108,
            left: 12,
            right: 12,
            child: _OffRouteBanner(onRecalculate: () => _loadRoute(current)),
          ),
        Positioned(
          bottom: 16,
          left: 12,
          right: 12,
          child: _TripSummaryBar(
            distanceMeters: route.totalDistanceMeters,
            durationSeconds: route.totalDurationSeconds,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
        if (_arrived) _ArrivalOverlay(brand: widget.station.brand),
      ],
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.angle,
    required this.distanceMeters,
    required this.instruction,
  });

  final double angle;
  final double distanceMeters;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: angle * math.pi / 180,
                child: Icon(
                  Icons.navigation_rounded,
                  size: 28,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${distanceMeters.round()} m',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  Text(
                    instruction,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OffRouteBanner extends StatelessWidget {
  const _OffRouteBanner({required this.onRecalculate});

  final VoidCallback onRecalculate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.tertiaryContainer,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.navOffRouteMessage,
                style: TextStyle(color: colorScheme.onTertiaryContainer),
              ),
            ),
            TextButton(
              onPressed: onRecalculate,
              child: Text(l10n.navRecalculate),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSummaryBar extends StatelessWidget {
  const _TripSummaryBar({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.onCancel,
  });

  final double distanceMeters;
  final double durationSeconds;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.route_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${(distanceMeters / 1000).toStringAsFixed(1)} km · '
                  '${(durationSeconds / 60).round()} min',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded),
              label: Text(context.l10n.commonCancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrivalOverlay extends StatelessWidget {
  const _ArrivalOverlay({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_gas_station_rounded,
                      size: 32, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.navArrived,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                if (brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(brand, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(context.l10n.navBackToList),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
