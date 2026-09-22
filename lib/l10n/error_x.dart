import '../services/fuel_price_service.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import 'gen/app_localizations.dart';

/// Traduce las excepciones propias de la app a un mensaje en el idioma
/// activo. Para cualquier otro error (p.ej. de red, sin tipo propio) usa
/// `toString()` como reserva.
String localizedErrorMessage(Object error, AppLocalizations l10n) {
  if (error is LocationException) return error.localizedMessage(l10n);
  if (error is FuelPriceException) return error.localizedMessage(l10n);
  if (error is RoutingException) return error.localizedMessage(l10n);
  return error.toString();
}
