import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/api_keys.dart';
import '../l10n/gen/app_localizations.dart';

/// Un paso de la ruta (un tramo entre dos maniobras) con su instrucción ya
/// en el idioma pedido.
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

  /// Tipo/modificador de maniobra (p.ej. "turn" / "left"), pensados para
  /// que la interfaz elija qué icono de flecha mostrar.
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

/// Idiomas de instrucciones de navegación soportados por OpenRouteService
/// que también soporta la app. Si el idioma activo no está aquí, se usa
/// inglés como reserva.
const _orsSupportedLanguages = {'es', 'en', 'fr'};

/// Calcula rutas de coche usando la API de pago de OpenRouteService
/// (openrouteservice.org), con plan gratuito que sobra para probar la app
/// o un lanzamiento pequeño. Sustituye al servidor de demo de OSRM, que no
/// está pensado para tráfico de producción real.
///
/// Necesita una API key propia en [ApiKeys.openRouteService] (ver
/// lib/config/api_keys.dart para instrucciones de cómo conseguirla).
class RoutingService {
  static const _baseUrl =
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    String languageCode = 'es',
  }) async {
    final orsLanguage =
        _orsSupportedLanguages.contains(languageCode) ? languageCode : 'en';
    final uri = Uri.parse(_baseUrl);
    final response = await http
        .post(
          uri,
          headers: {
            'Authorization': ApiKeys.openRouteService,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'coordinates': [
              [origin.longitude, origin.latitude],
              [destination.longitude, destination.latitude],
            ],
            'language': orsLanguage,
            'instructions': true,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw _exceptionFor(response);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final features = json['features'] as List?;
    if (features == null || features.isEmpty) {
      throw RoutingException.noRoute();
    }

    final feature = features.first as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = (geometry['coordinates'] as List)
        .map((c) => LatLng((c as List)[1] as double, c[0] as double))
        .toList();

    final properties = feature['properties'] as Map<String, dynamic>;
    final segment =
        (properties['segments'] as List).first as Map<String, dynamic>;

    final steps = <RouteStep>[];
    for (final rawStep in segment['steps'] as List) {
      final step = rawStep as Map<String, dynamic>;
      final wayPoints = step['way_points'] as List;
      final startIndex = (wayPoints.first as num).toInt();
      final streetName = (step['name'] as String?)?.trim() ?? '';
      final normalizedStreetName = streetName == '-' ? '' : streetName;
      final maneuverModifier = _modifierFor(step['type'] as int? ?? -1);

      steps.add(RouteStep(
        maneuverLocation: coordinates[startIndex],
        instruction: step['instruction'] as String? ?? '',
        streetName: normalizedStreetName,
        distanceMeters: (step['distance'] as num).toDouble(),
        durationSeconds: (step['duration'] as num).toDouble(),
        maneuverType: (step['type'] as int? ?? -1).toString(),
        maneuverModifier: maneuverModifier,
      ));
    }

    return RouteResult(
      polyline: coordinates,
      steps: steps,
      totalDistanceMeters: (segment['distance'] as num).toDouble(),
      totalDurationSeconds: (segment['duration'] as num).toDouble(),
    );
  }

  /// Traduce el código numérico de maniobra de OpenRouteService al mismo
  /// vocabulario de modificadores que ya usaba la interfaz (para elegir el
  /// ángulo de la flecha de navegación). Códigos documentados en
  /// https://openrouteservice.org/dev/#/api-docs/v2/directions/{profile}/post
  String _modifierFor(int type) {
    switch (type) {
      case 0:
        return 'left';
      case 1:
        return 'right';
      case 2:
        return 'sharp left';
      case 3:
        return 'sharp right';
      case 4:
        return 'slight left';
      case 5:
        return 'slight right';
      case 6:
        return 'straight';
      case 9:
        return 'uturn';
      case 12:
        return 'slight left';
      case 13:
        return 'slight right';
      default:
        return 'straight';
    }
  }

  RoutingException _exceptionFor(http.Response response) {
    if (response.statusCode == 403) {
      return RoutingException.invalidKey();
    }
    if (response.statusCode == 429) {
      return RoutingException.rateLimited();
    }
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final message = (json['error'] is Map)
          ? (json['error'] as Map)['message']
          : json['error'];
      if (message is String && message.isNotEmpty) {
        return RoutingException.withMessage(message);
      }
    } catch (_) {
      // Cuerpo no era JSON con el formato esperado: usamos el mensaje genérico.
    }
    return RoutingException.withCode(response.statusCode);
  }
}

enum RoutingErrorReason { invalidKey, rateLimited, withMessage, withCode, noRoute }

class RoutingException implements Exception {
  RoutingException.invalidKey()
      : reason = RoutingErrorReason.invalidKey,
        message = null,
        code = null;
  RoutingException.rateLimited()
      : reason = RoutingErrorReason.rateLimited,
        message = null,
        code = null;
  RoutingException.withMessage(String this.message)
      : reason = RoutingErrorReason.withMessage,
        code = null;
  RoutingException.withCode(int this.code)
      : reason = RoutingErrorReason.withCode,
        message = null;
  RoutingException.noRoute()
      : reason = RoutingErrorReason.noRoute,
        message = null,
        code = null;

  final RoutingErrorReason reason;
  final String? message;
  final int? code;

  String localizedMessage(AppLocalizations l10n) {
    switch (reason) {
      case RoutingErrorReason.invalidKey:
        return l10n.routingKeyInvalid;
      case RoutingErrorReason.rateLimited:
        return l10n.routingRateLimited;
      case RoutingErrorReason.withMessage:
        return l10n.routingGenericErrorWithMessage(message!);
      case RoutingErrorReason.withCode:
        return l10n.routingGenericErrorWithCode(code!);
      case RoutingErrorReason.noRoute:
        return l10n.routingNoRoute;
    }
  }

  @override
  String toString() => 'RoutingException(${reason.name})';
}
