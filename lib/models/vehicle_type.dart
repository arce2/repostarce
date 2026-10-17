import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';

/// Tipo de vehículo, para diferenciarlos de un vistazo (icono distinto) en
/// "Mis vehículos" en vez de que todos se vean igual.
enum VehicleType {
  car,
  motorcycle,
  pickup;

  /// Nombre legible en el idioma activo.
  String labelFor(AppLocalizations l10n) {
    switch (this) {
      case VehicleType.car:
        return l10n.vehicleTypeCar;
      case VehicleType.motorcycle:
        return l10n.vehicleTypeMotorcycle;
      case VehicleType.pickup:
        return l10n.vehicleTypePickup;
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.car:
        return Icons.directions_car_rounded;
      case VehicleType.motorcycle:
        return Icons.two_wheeler_rounded;
      case VehicleType.pickup:
        return Icons.local_shipping_rounded;
    }
  }
}
