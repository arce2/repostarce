import '../l10n/gen/app_localizations.dart';

/// Tipos de combustible soportados por la app.
///
/// El campo [apiField] es el nombre EXACTO de la clave que usa la API REST
/// pública del Ministerio para la Transición Ecológica y el Reto Demográfico
/// (Geoportal de Precios de Carburantes) para ese combustible.
enum FuelType {
  gasolina95('Precio Gasolina 95 E5'),
  gasolina98('Precio Gasolina 98 E5'),
  gasoleoA('Precio Gasoleo A'),
  gasoleoPremium('Precio Gasoleo Premium'),
  glp('Precio Gases licuados del petróleo');

  const FuelType(this.apiField);

  /// Clave exacta dentro del JSON de cada estación.
  final String apiField;

  /// Nombre legible para mostrar en la interfaz, en el idioma activo.
  String labelFor(AppLocalizations l10n) {
    switch (this) {
      case FuelType.gasolina95:
        return l10n.fuelGasolina95;
      case FuelType.gasolina98:
        return l10n.fuelGasolina98;
      case FuelType.gasoleoA:
        return l10n.fuelGasoleoA;
      case FuelType.gasoleoPremium:
        return l10n.fuelGasoleoPremium;
      case FuelType.glp:
        return l10n.fuelGlp;
    }
  }
}
