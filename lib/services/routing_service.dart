import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Un paso de la ruta (un tramo entre dos maniobras) con su instrucción ya
/// traducida al español.
class RouteStep {
  RouteStep({
    required this.maneuverLocation,
    required this.instruction,
    required this.streetName,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.maneuverType,
    required this.maneuverModifier,
  });

  final LatLng maneuverLocation;
  final String instruction;
  final String streetName;
  final double distanceMeters;
  final double durationSeconds;

  /// Tipo/modificador crudos de OSRM (p.ej. "turn" / "left"), pensados
  /// para que la interfaz elija qué icono de flecha mostrar.
  final String maneuverType;
  final String maneuverModifier;
}

/// Ruta completa: geometría para dibujar en el mapa + pasos para la
/// navegación turn-by-turn.
class RouteResult {
  RouteResult({
    required this.polyline,
    required this.steps,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });

  final List<LatLng> polyline;
  final List<RouteStep> steps;
  final double totalDistanceMeters;
  final double totalDurationSeconds;
}

/// Calcula rutas de coche usando el servidor público de demostración de
/// OSRM (Open Source Routing Machine) sobre datos de OpenStreetMap.
///
/// IMPORTANTE: `router.project-osrm.org` es un servidor de DEMO gratuito,
/// sin API key, pero pensado para pruebas ligeras (ver su fair-use policy).
/// No tiene garantías de disponibilidad ni de límite de peticiones. Para
/// una app en producción real habría que montar tu propio servidor OSRM
/// (o usar un proveedor de pago tipo Mapbox/Google) — ver README.
class RoutingService {
  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final coords =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final uri = Uri.parse(
      '$_baseUrl/$coords?overview=full&geometries=geojson&steps=true',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw RoutingException(
        'No se ha podido calcular la ruta (código ${response.statusCode}). '
        'Inténtalo de nuevo.',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 'Ok' ||
        (json['routes'] as List?)?.isNotEmpty != true) {
      throw RoutingException(
        'No se ha encontrado una ruta en coche hasta esa gasolinera.',
      );
    }

    final route = (json['routes'] as List).first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = (geometry['coordinates'] as List)
        .map((c) => LatLng((c as List)[1] as double, c[0] as double))
        .toList();

    final legs = route['legs'] as List;
    final steps = <RouteStep>[];
    for (final leg in legs) {
      for (final rawStep in (leg as Map<String, dynamic>)['steps'] as List) {
        final step = rawStep as Map<String, dynamic>;
        final maneuver = step['maneuver'] as Map<String, dynamic>;
        final location = maneuver['location'] as List;
        final streetName = (step['name'] as String?)?.trim() ?? '';

        steps.add(RouteStep(
          maneuverLocation: LatLng(
            (location[1] as num).toDouble(),
            (location[0] as num).toDouble(),
          ),
          instruction: _instructionFor(maneuver, streetName),
          streetName: streetName,
          distanceMeters: (step['distance'] as num).toDouble(),
          durationSeconds: (step['duration'] as num).toDouble(),
          maneuverType: maneuver['type'] as String? ?? '',
          maneuverModifier: maneuver['modifier'] as String? ?? '',
        ));
      }
    }

    return RouteResult(
      polyline: coordinates,
      steps: steps,
      totalDistanceMeters: (route['distance'] as num).toDouble(),
      totalDurationSeconds: (route['duration'] as num).toDouble(),
    );
  }

  /// Traduce el tipo/modificador de maniobra de OSRM a una instrucción en
  /// español. Vocabulario estándar de OSRM:
  /// https://project-osrm.org/docs/v5.24.0/api/#stepmaneuver-object
  String _instructionFor(Map<String, dynamic> maneuver, String streetName) {
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';
    final hacia = streetName.isNotEmpty ? ' hacia $streetName' : '';
    final porCalle = streetName.isNotEmpty ? ' por $streetName' : '';

    String turnPhrase() {
      switch (modifier) {
        case 'uturn':
          return 'Haz un cambio de sentido';
        case 'sharp left':
          return 'Gira bruscamente a la izquierda$hacia';
        case 'left':
          return 'Gira a la izquierda$hacia';
        case 'slight left':
          return 'Gira ligeramente a la izquierda$hacia';
        case 'straight':
          return 'Sigue recto$porCalle';
        case 'slight right':
          return 'Gira ligeramente a la derecha$hacia';
        case 'right':
          return 'Gira a la derecha$hacia';
        case 'sharp right':
          return 'Gira bruscamente a la derecha$hacia';
        default:
          return 'Continúa$porCalle';
      }
    }

    switch (type) {
      case 'depart':
        return streetName.isNotEmpty
            ? 'Empieza en $streetName'
            : 'Empieza la ruta';
      case 'arrive':
        return 'Has llegado a tu destino';
      case 'turn':
      case 'roundabout turn':
        return turnPhrase();
      case 'new name':
      case 'continue':
        return 'Continúa$porCalle';
      case 'merge':
        return 'Incorpórate$hacia';
      case 'on ramp':
        return 'Toma la salida$hacia';
      case 'off ramp':
        return 'Sal de la vía$hacia';
      case 'fork':
        return modifier.contains('left')
            ? 'Mantente a la izquierda$hacia'
            : 'Mantente a la derecha$hacia';
      case 'end of road':
        return modifier.contains('left')
            ? 'Al final de la calle, gira a la izquierda$hacia'
            : 'Al final de la calle, gira a la derecha$hacia';
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'];
        return exit != null
            ? 'En la rotonda, toma la salida $exit$hacia'
            : 'Entra en la rotonda$hacia';
      case 'exit roundabout':
      case 'exit rotary':
        return 'Sal de la rotonda$hacia';
      case 'use lane':
        return 'Mantente en el carril$porCalle';
      default:
        return streetName.isNotEmpty ? 'Continúa$porCalle' : 'Continúa';
    }
  }
}

class RoutingException implements Exception {
  RoutingException(this.message);
  final String message;

  @override
  String toString() => message;
}
