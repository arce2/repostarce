// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonGasStationFallback => 'Gasolinera';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get appTabHome => 'Buscar';

  @override
  String get appTabFuelLog => 'Consumo';

  @override
  String get appTabSettings => 'Ajustes';

  @override
  String get homeHeadline => 'Encuentra la gasolinera\nmás barata';

  @override
  String get homeSubtitle =>
      'Compara precios cerca de ti y te llevamos hasta allí paso a paso, sin salir de la app.';

  @override
  String get homeFavoritesTitle => 'Tus favoritas';

  @override
  String get homeFavoritesEmptyHint =>
      'Toca la ⭐ en cualquier gasolinera para guardarla aquí y ver su precio sin buscarla cada vez.';

  @override
  String get homeUseLocationButton => 'Usar mi ubicación actual';

  @override
  String get homeUseLocationLoading => 'Buscando tu ubicación…';

  @override
  String get homeSearchByZoneDivider => 'O BUSCA POR ZONA';

  @override
  String get homeProvinceLabel => 'Elige tu provincia';

  @override
  String get homeSearchProvinceButton => 'Buscar en esta provincia';

  @override
  String get homeErrorChooseProvince =>
      'Elige antes una provincia de la lista.';

  @override
  String get homeFuelLogCardTitle => 'Consumo y gastos';

  @override
  String get homeFuelLogCardSubtitle =>
      'Apunta tus repostajes y consulta tu consumo medio';

  @override
  String get homeSettingsTooltip => 'Ajustes';

  @override
  String get resultsTitleNearby => 'Cerca de ti';

  @override
  String get resultsListViewTooltip => 'Ver lista';

  @override
  String get resultsMapViewTooltip => 'Ver mapa';

  @override
  String get resultsSearchHint => 'Buscar gasolinera, calle o pueblo…';

  @override
  String resultsFilteringChip(String query) {
    return 'Filtrando: \"$query\"';
  }

  @override
  String get results24hFilter => 'Abierto 24h';

  @override
  String get resultsMunicipalityLabel => 'Municipio';

  @override
  String get resultsAllMunicipalities => 'Todos los municipios';

  @override
  String get resultsLocalityLabel => 'Localidad';

  @override
  String get resultsAllLocalities => 'Todos los pueblos';

  @override
  String get resultsCheapestLabel => 'Más barata';

  @override
  String get resultsMostExpensiveLabel => 'Más cara';

  @override
  String resultsNoMatchSearch(String query) {
    return 'Ninguna gasolinera coincide con \"$query\" aquí.';
  }

  @override
  String get resultsNo24h => 'No hay gasolineras abiertas 24h aquí.';

  @override
  String resultsNoFuelType(String fuel) {
    return 'No hay gasolineras que vendan $fuel por aquí.';
  }

  @override
  String get resultsNearbyTitle => 'También cerca de ti';

  @override
  String get resultsNearbySubtitle =>
      'Hay pocas gasolineras en tu localidad; estas están a menos de 20 km.';

  @override
  String navTitle(String brand) {
    return 'A $brand';
  }

  @override
  String get navGasStationFallback => 'la gasolinera';

  @override
  String get navRecalcTooltip => 'Recalcular ruta';

  @override
  String get navOffRouteMessage => 'Parece que te has salido de la ruta';

  @override
  String get navRecalculate => 'Recalcular';

  @override
  String get navArrived => '¡Has llegado!';

  @override
  String get navBackToList => 'Volver a la lista';

  @override
  String get stationCheapestBadge => 'más barata';

  @override
  String get stationMostExpensiveBadge => 'más cara';

  @override
  String get stationRemoveFavoriteTooltip => 'Quitar de favoritas';

  @override
  String get stationSaveFavoriteTooltip => 'Guardar como favorita';

  @override
  String get stationCalculatingRoute => 'Calculando ruta…';

  @override
  String get stationNavigateButton => 'Navegar hasta aquí';

  @override
  String stationCheaperNearby(String brand, String savings, int liters) {
    return 'Hay una más barata cerca ($brand): ahorras $savings € en un depósito de $liters L. Toca para verla.';
  }

  @override
  String fuelPriceServiceError(int code) {
    return 'El servicio de precios de carburantes no respondió correctamente (código $code). Inténtalo de nuevo en unos minutos.';
  }

  @override
  String get routingKeyInvalid =>
      'La clave de OpenRouteService no es válida o no está configurada.';

  @override
  String get routingRateLimited =>
      'Se ha superado el límite de peticiones de rutas por hoy. Inténtalo más tarde.';

  @override
  String routingGenericErrorWithMessage(String message) {
    return 'No se ha podido calcular la ruta: $message';
  }

  @override
  String routingGenericErrorWithCode(int code) {
    return 'No se ha podido calcular la ruta (código $code). Inténtalo de nuevo.';
  }

  @override
  String get routingNoRoute =>
      'No se ha encontrado una ruta en coche hasta esa gasolinera.';

  @override
  String get locationGpsDisabled =>
      'El GPS está desactivado. Actívalo en los ajustes del teléfono para poder buscar gasolineras cerca de ti.';

  @override
  String get locationPermissionDenied =>
      'Necesito permiso de ubicación para encontrar gasolineras cerca de ti. También puedes elegir tu provincia manualmente.';

  @override
  String get locationPermissionBlocked =>
      'El permiso de ubicación está bloqueado para esta app. Actívalo desde los ajustes del sistema, o elige tu provincia manualmente.';

  @override
  String get priceAlertChannelName => 'Cambios de precio';

  @override
  String get priceAlertChannelDesc =>
      'Avisa cuando sube o baja el precio de una gasolinera favorita';

  @override
  String priceAlertDropTitle(String brand) {
    return '¡Bajó el precio en $brand!';
  }

  @override
  String priceAlertRiseTitle(String brand) {
    return 'Subió el precio en $brand';
  }

  @override
  String priceAlertBody(String newPrice, String oldPrice) {
    return 'Ahora a $newPrice € (antes $oldPrice €)';
  }

  @override
  String get priceAlertFallbackBrand => 'tu favorita';

  @override
  String get fuelGasolina95 => 'Gasolina 95';

  @override
  String get fuelGasolina98 => 'Gasolina 98';

  @override
  String get fuelGasoleoA => 'Diésel (Gasóleo A)';

  @override
  String get fuelGasoleoPremium => 'Diésel Premium';

  @override
  String get fuelGlp => 'GLP (Autogás)';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del sistema';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLegalLabel => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsLegalNotice => 'Aviso legal';

  @override
  String get fuelLogTitle => 'Consumo y gastos';

  @override
  String get fuelLogAddTooltip => 'Añadir repostaje';

  @override
  String get fuelLogFormTitle => 'Nuevo repostaje';

  @override
  String get fuelLogFormFuelType => 'Combustible';

  @override
  String get fuelLogFormLiters => 'Litros';

  @override
  String get fuelLogFormPrice => 'Precio total (€)';

  @override
  String get fuelLogFormKm => 'Km recorridos desde el último repostaje';

  @override
  String get fuelLogFormSave => 'Guardar repostaje';

  @override
  String get fuelLogValidationRequired => 'Obligatorio';

  @override
  String get fuelLogValidationNumber => 'Introduce un número válido';

  @override
  String get fuelLogEmptyState =>
      'Aún no has registrado ningún repostaje. Añade el primero para empezar a ver tu consumo medio.';

  @override
  String get fuelLogAverageConsumption => 'Consumo medio';

  @override
  String get fuelLogConsumptionUnit => 'L/100km';

  @override
  String get fuelLogTotalSpent => 'Gastado en total';

  @override
  String get fuelLogHistoryTitle => 'Historial de repostajes';

  @override
  String fuelLogEntrySubtitle(String liters, String km, String price) {
    return '$liters L · $km km · $price €';
  }

  @override
  String get fuelLogDeleteTooltip => 'Eliminar repostaje';

  @override
  String get fuelLogRecommendationsTitle => 'Recomendaciones para ti';

  @override
  String get fuelLogRecommendationsEmpty =>
      'Registra un par de repostajes y algún trayecto navegado más para recibir recomendaciones personalizadas.';

  @override
  String recoConsumptionRising(String percent) {
    return 'Tu consumo medio ha subido un $percent% últimamente. Revisa la presión de los neumáticos y el filtro de aire: pueden estar disparando el gasto.';
  }

  @override
  String recoConsumptionImproving(String percent) {
    return 'Tu consumo medio ha bajado un $percent% respecto a tus repostajes anteriores. Vas por buen camino.';
  }

  @override
  String recoHighSpeed(String speed) {
    return 'Tu velocidad media en trayectos recientes ($speed km/h) es alta. Reducir la velocidad en carretera puede bajar tu consumo notablemente.';
  }

  @override
  String recoLowSpeedHighConsumption(String speed) {
    return 'Tus trayectos recientes son cortos y a poca velocidad media ($speed km/h), lo que suele disparar el consumo por ciudad. Si puedes, agrupa varios recados en un solo trayecto.';
  }

  @override
  String get recoAllGood =>
      'Tu consumo y tu forma de conducir están dentro de lo normal. Sigue así.';

  @override
  String get fuelLogVehicleLabel => 'Vehículo';

  @override
  String get fuelLogDefaultVehicleName => 'Mi coche';

  @override
  String get fuelLogManageVehiclesTooltip => 'Gestionar vehículos';

  @override
  String get fuelLogManageVehiclesTitle => 'Tus vehículos';

  @override
  String get fuelLogAddVehicleHint =>
      'Nombre del vehículo (p. ej. Coche, Moto)';

  @override
  String get fuelLogAddVehicleButton => 'Añadir';

  @override
  String get fuelLogDeleteVehicleTooltip => 'Eliminar vehículo';

  @override
  String get fuelLogCannotDeleteLastVehicle =>
      'Tiene que quedar al menos un vehículo.';

  @override
  String navEstimatedCost(String cost) {
    return 'Coste estimado: $cost €';
  }

  @override
  String get stationPriceTrendTitle => 'Evolución de precio (favorita)';
}
