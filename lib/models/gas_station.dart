import 'dart:math' as math;

import 'fuel_type.dart';

/// Una gasolinera, tal y como la devuelve la API del Ministerio, ya
/// parseada a tipos Dart normales (los precios y coordenadas de la API
/// vienen como texto con coma decimal, p.ej. "1,479").
class GasStation {
  GasStation({
    required this.id,
    required this.brand,
    required this.address,
    required this.locality,
    required this.municipality,
    required this.province,
    required this.provinceId,
    required this.postalCode,
    required this.schedule,
    required this.latitude,
    required this.longitude,
    required this.prices,
    this.distanceKm,
  });

  final String id;
  final String brand;
  final String address;
  final String locality;
  final String municipality;
  final String province;

  /// Código INE de provincia (p.ej. "30" para Murcia), tal cual lo manda
  /// la API en el campo `IDProvincia`. Se usa para el filtro manual por
  /// provincia (ver [Province]).
  final String provinceId;
  final String postalCode;
  final String schedule;
  final double latitude;
  final double longitude;

  /// Precio por tipo de combustible. `null` significa que esa gasolinera
  /// no vende ese combustible (la API deja el campo vacío en ese caso).
  final Map<FuelType, double?> prices;

  /// Distancia en línea recta (km) hasta el punto de referencia del
  /// usuario. Se rellena a posteriori con [distanceTo], no viene de la API.
  double? distanceKm;

  double? priceFor(FuelType type) => prices[type];

  /// true si el horario indica servicio 24 horas (la API lo expresa como
  /// "L-D: 24H" en vez de un rango de horas).
  bool get isOpen24h => schedule.toUpperCase().contains('24H');

  /// Tipos de combustible que esta estación realmente vende.
  List<FuelType> get availableFuelTypes =>
      FuelType.values.where((t) => prices[t] != null).toList();

  factory GasStation.fromJson(Map<String, dynamic> json) {
    double? parseDecimal(dynamic raw) {
      if (raw == null) return null;
      final text = raw.toString().trim();
      if (text.isEmpty) return null;
      return double.tryParse(text.replaceAll(',', '.'));
    }

    String parseText(dynamic raw) => (raw ?? '').toString().trim();

    final prices = <FuelType, double?>{
      for (final type in FuelType.values)
        type: parseDecimal(json[type.apiField]),
    };

    return GasStation(
      id: parseText(json['IDEESS']),
      brand: parseText(json['Rótulo']),
      address: parseText(json['Dirección']),
      locality: parseText(json['Localidad']),
      municipality: parseText(json['Municipio']),
      province: parseText(json['Provincia']),
      provinceId: parseText(json['IDProvincia']),
      postalCode: parseText(json['C.P.']),
      schedule: parseText(json['Horario']),
      // Ojo: la clave incluye literalmente "(WGS84)".
      latitude: parseDecimal(json['Latitud']) ?? 0,
      longitude: parseDecimal(json['Longitud (WGS84)']) ?? 0,
      prices: prices,
    );
  }

  /// Distancia Haversine en km entre esta estación y (lat, lng).
  double distanceTo(double lat, double lng) {
    const earthRadiusKm = 6371.0;
    double toRad(double deg) => deg * math.pi / 180;

    final dLat = toRad(lat - latitude);
    final dLng = toRad(lng - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(latitude)) *
            math.cos(toRad(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
