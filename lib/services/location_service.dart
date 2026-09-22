import 'package:geolocator/geolocator.dart';

import '../l10n/gen/app_localizations.dart';

/// Envuelve `geolocator` para pedir permisos y obtener la posición del
/// usuario, tanto una vez (pantalla de inicio) como en directo (navegación).
class LocationService {
  /// Comprueba servicio de ubicación + permisos y, si todo está bien,
  /// devuelve la posición actual. Lanza [LocationException] si algo falla.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(LocationErrorReason.gpsDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(LocationErrorReason.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(LocationErrorReason.permissionBlocked);
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

enum LocationErrorReason { gpsDisabled, permissionDenied, permissionBlocked }

class LocationException implements Exception {
  LocationException(this.reason);
  final LocationErrorReason reason;

  String localizedMessage(AppLocalizations l10n) {
    switch (reason) {
      case LocationErrorReason.gpsDisabled:
        return l10n.locationGpsDisabled;
      case LocationErrorReason.permissionDenied:
        return l10n.locationPermissionDenied;
      case LocationErrorReason.permissionBlocked:
        return l10n.locationPermissionBlocked;
    }
  }

  @override
  String toString() => 'LocationException(${reason.name})';
}
