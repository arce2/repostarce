import 'package:geolocator/geolocator.dart';

/// Envuelve `geolocator` para pedir permisos y obtener la posición del
/// usuario, tanto una vez (pantalla de inicio) como en directo (navegación).
class LocationService {
  /// Comprueba servicio de ubicación + permisos y, si todo está bien,
  /// devuelve la posición actual. Lanza [LocationException] con un mensaje
  /// en español listo para mostrar si algo falla.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'El GPS está desactivado. Actívalo en los ajustes del teléfono '
        'para poder buscar gasolineras cerca de ti.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Necesito permiso de ubicación para encontrar gasolineras cerca '
          'de ti. También puedes elegir tu provincia manualmente.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'El permiso de ubicación está bloqueado para esta app. Actívalo '
        'desde los ajustes del sistema, o elige tu provincia manualmente.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Stream de posición en vivo, usado durante la navegación turn-by-turn.
  /// [distanceFilterMeters] evita recalcular en cada centímetro.
  Stream<Position> watchPosition({double distanceFilterMeters = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilterMeters.round(),
      ),
    );
  }
}

class LocationException implements Exception {
  LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}
