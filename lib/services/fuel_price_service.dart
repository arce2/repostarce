import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fuel_type.dart';
import '../models/gas_station.dart';

/// Habla con la API REST pública y gratuita del Ministerio para la
/// Transición Ecológica y el Reto Demográfico (Geoportal de Precios de
/// Carburantes). No requiere API key.
///
/// Documentación oficial (PDF "Manual de Integración"):
/// https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/
class FuelPriceService {
  static const _baseUrl =
      'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes';

  // La API no pagina y devuelve unas 11.000 estaciones de golpe (~6-8 MB).
  // Lo cacheamos en memoria durante la sesión para no volver a descargarlo
  // cada vez que el usuario cambia de filtro.
  List<GasStation>? _cache;
  DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 20);

  Future<List<GasStation>> _fetchAllStations() async {
    final isFresh = _cache != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl;
    if (isFresh) return _cache!;

    final uri = Uri.parse('$_baseUrl/EstacionesTerrestres/');
    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw FuelPriceException(
        'El servicio de precios de carburantes no respondió correctamente '
        '(código ${response.statusCode}). Inténtalo de nuevo en unos minutos.',
      );
    }

    // La API devuelve utf8, aunque el header diga otra cosa.
    final decodedBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> json = jsonDecode(decodedBody);
    final List<dynamic> raw = json['ListaEESSPrecio'] as List<dynamic>? ?? [];

    final stations = raw
        .cast<Map<String, dynamic>>()
        .map(GasStation.fromJson)
        // Descartamos entradas sin coordenadas válidas.
        .where((s) => s.latitude != 0 && s.longitude != 0)
        .toList();

    _cache = stations;
    _cachedAt = DateTime.now();
    return stations;
  }

  /// Fuerza que la próxima consulta vuelva a descargar los precios del
  /// Ministerio en vez de usar la caché en memoria, para poder detectar
  /// cambios de precio mientras la app sigue abierta.
  void refresh() {
    _cache = null;
    _cachedAt = null;
  }

  /// Gasolineras dentro de [radiusKm] de (lat, lng), con [GasStation.distanceKm]
  /// ya calculado. Si hay menos de [minResults], va doblando el radio (hasta
  /// [maxRadiusKm]) para que en zonas rurales no se quede la lista vacía.
  Future<List<GasStation>> findNearby({
    required double lat,
    required double lng,
    double initialRadiusKm = 10,
    int minResults = 5,
    double maxRadiusKm = 100,
  }) async {
    final all = await _fetchAllStations();

    var radius = initialRadiusKm;
    List<GasStation> found = [];
    while (true) {
      found = all.where((s) {
        s.distanceKm = s.distanceTo(lat, lng);
        return s.distanceKm! <= radius;
      }).toList();

      if (found.length >= minResults || radius >= maxRadiusKm) break;
      radius *= 2;
    }

    found.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return found;
  }

  /// Gasolineras de una provincia concreta (código INE de dos dígitos).
  /// No calcula distancia porque no hay un punto de referencia único.
  Future<List<GasStation>> findByProvince(String provinceId) async {
    final all = await _fetchAllStations();
    return all.where((s) => s.provinceId == provinceId).toList();
  }

  /// Gasolineras concretas por su [GasStation.id] (IDEESS), sin importar la
  /// provincia. Se usa para recuperar las gasolineras favoritas guardadas.
  Future<List<GasStation>> findByIds(Set<String> ids) async {
    if (ids.isEmpty) return [];
    final all = await _fetchAllStations();
    return all.where((s) => ids.contains(s.id)).toList();
  }

  /// Ordena una lista de gasolineras por precio ascendente para [type],
  /// dejando fuera las que no venden ese combustible.
  List<GasStation> sortedByPrice(List<GasStation> stations, FuelType type) {
    final withPrice = stations.where((s) => s.priceFor(type) != null).toList()
      ..sort((a, b) => a.priceFor(type)!.compareTo(b.priceFor(type)!));
    return withPrice;
  }
}

class FuelPriceException implements Exception {
  FuelPriceException(this.message);
  final String message;

  @override
  String toString() => message;
}
