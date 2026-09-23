import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @commonGasStationFallback.
  ///
  /// In es, this message translates to:
  /// **'Gasolinera'**
  String get commonGasStationFallback;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @appTabHome.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get appTabHome;

  /// No description provided for @appTabFuelLog.
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get appTabFuelLog;

  /// No description provided for @appTabSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get appTabSettings;

  /// No description provided for @homeHeadline.
  ///
  /// In es, this message translates to:
  /// **'Encuentra la gasolinera\nmás barata'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Compara precios cerca de ti y te llevamos hasta allí paso a paso, sin salir de la app.'**
  String get homeSubtitle;

  /// No description provided for @homeFavoritesTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus favoritas'**
  String get homeFavoritesTitle;

  /// No description provided for @homeFavoritesEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Toca la ⭐ en cualquier gasolinera para guardarla aquí y ver su precio sin buscarla cada vez.'**
  String get homeFavoritesEmptyHint;

  /// No description provided for @homeUseLocationButton.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación actual'**
  String get homeUseLocationButton;

  /// No description provided for @homeUseLocationLoading.
  ///
  /// In es, this message translates to:
  /// **'Buscando tu ubicación…'**
  String get homeUseLocationLoading;

  /// No description provided for @homeSearchByZoneDivider.
  ///
  /// In es, this message translates to:
  /// **'O BUSCA POR ZONA'**
  String get homeSearchByZoneDivider;

  /// No description provided for @homeProvinceLabel.
  ///
  /// In es, this message translates to:
  /// **'Elige tu provincia'**
  String get homeProvinceLabel;

  /// No description provided for @homeSearchProvinceButton.
  ///
  /// In es, this message translates to:
  /// **'Buscar en esta provincia'**
  String get homeSearchProvinceButton;

  /// No description provided for @homeErrorChooseProvince.
  ///
  /// In es, this message translates to:
  /// **'Elige antes una provincia de la lista.'**
  String get homeErrorChooseProvince;

  /// No description provided for @homeFuelLogCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Consumo y gastos'**
  String get homeFuelLogCardTitle;

  /// No description provided for @homeFuelLogCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Apunta tus repostajes y consulta tu consumo medio'**
  String get homeFuelLogCardSubtitle;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get homeSettingsTooltip;

  /// No description provided for @resultsTitleNearby.
  ///
  /// In es, this message translates to:
  /// **'Cerca de ti'**
  String get resultsTitleNearby;

  /// No description provided for @resultsListViewTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ver lista'**
  String get resultsListViewTooltip;

  /// No description provided for @resultsMapViewTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ver mapa'**
  String get resultsMapViewTooltip;

  /// No description provided for @resultsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar gasolinera, calle o pueblo…'**
  String get resultsSearchHint;

  /// No description provided for @resultsFilteringChip.
  ///
  /// In es, this message translates to:
  /// **'Filtrando: \"{query}\"'**
  String resultsFilteringChip(String query);

  /// No description provided for @results24hFilter.
  ///
  /// In es, this message translates to:
  /// **'Abierto 24h'**
  String get results24hFilter;

  /// No description provided for @resultsMunicipalityLabel.
  ///
  /// In es, this message translates to:
  /// **'Municipio'**
  String get resultsMunicipalityLabel;

  /// No description provided for @resultsAllMunicipalities.
  ///
  /// In es, this message translates to:
  /// **'Todos los municipios'**
  String get resultsAllMunicipalities;

  /// No description provided for @resultsLocalityLabel.
  ///
  /// In es, this message translates to:
  /// **'Localidad'**
  String get resultsLocalityLabel;

  /// No description provided for @resultsAllLocalities.
  ///
  /// In es, this message translates to:
  /// **'Todos los pueblos'**
  String get resultsAllLocalities;

  /// No description provided for @resultsCheapestLabel.
  ///
  /// In es, this message translates to:
  /// **'Más barata'**
  String get resultsCheapestLabel;

  /// No description provided for @resultsMostExpensiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Más cara'**
  String get resultsMostExpensiveLabel;

  /// No description provided for @resultsNoMatchSearch.
  ///
  /// In es, this message translates to:
  /// **'Ninguna gasolinera coincide con \"{query}\" aquí.'**
  String resultsNoMatchSearch(String query);

  /// No description provided for @resultsNo24h.
  ///
  /// In es, this message translates to:
  /// **'No hay gasolineras abiertas 24h aquí.'**
  String get resultsNo24h;

  /// No description provided for @resultsNoFuelType.
  ///
  /// In es, this message translates to:
  /// **'No hay gasolineras que vendan {fuel} por aquí.'**
  String resultsNoFuelType(String fuel);

  /// No description provided for @resultsNearbyTitle.
  ///
  /// In es, this message translates to:
  /// **'También cerca de ti'**
  String get resultsNearbyTitle;

  /// No description provided for @resultsNearbySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Hay pocas gasolineras en tu localidad; estas están a menos de 20 km.'**
  String get resultsNearbySubtitle;

  /// No description provided for @navTitle.
  ///
  /// In es, this message translates to:
  /// **'A {brand}'**
  String navTitle(String brand);

  /// No description provided for @navGasStationFallback.
  ///
  /// In es, this message translates to:
  /// **'la gasolinera'**
  String get navGasStationFallback;

  /// No description provided for @navRecalcTooltip.
  ///
  /// In es, this message translates to:
  /// **'Recalcular ruta'**
  String get navRecalcTooltip;

  /// No description provided for @navOffRouteMessage.
  ///
  /// In es, this message translates to:
  /// **'Parece que te has salido de la ruta'**
  String get navOffRouteMessage;

  /// No description provided for @navRecalculate.
  ///
  /// In es, this message translates to:
  /// **'Recalcular'**
  String get navRecalculate;

  /// No description provided for @navArrived.
  ///
  /// In es, this message translates to:
  /// **'¡Has llegado!'**
  String get navArrived;

  /// No description provided for @navBackToList.
  ///
  /// In es, this message translates to:
  /// **'Volver a la lista'**
  String get navBackToList;

  /// No description provided for @stationCheapestBadge.
  ///
  /// In es, this message translates to:
  /// **'más barata'**
  String get stationCheapestBadge;

  /// No description provided for @stationMostExpensiveBadge.
  ///
  /// In es, this message translates to:
  /// **'más cara'**
  String get stationMostExpensiveBadge;

  /// No description provided for @stationRemoveFavoriteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritas'**
  String get stationRemoveFavoriteTooltip;

  /// No description provided for @stationSaveFavoriteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Guardar como favorita'**
  String get stationSaveFavoriteTooltip;

  /// No description provided for @stationCalculatingRoute.
  ///
  /// In es, this message translates to:
  /// **'Calculando ruta…'**
  String get stationCalculatingRoute;

  /// No description provided for @stationNavigateButton.
  ///
  /// In es, this message translates to:
  /// **'Navegar hasta aquí'**
  String get stationNavigateButton;

  /// No description provided for @stationCheaperNearby.
  ///
  /// In es, this message translates to:
  /// **'Hay una más barata cerca ({brand}): ahorras {savings} € en un depósito de {liters} L. Toca para verla.'**
  String stationCheaperNearby(String brand, String savings, int liters);

  /// No description provided for @fuelPriceServiceError.
  ///
  /// In es, this message translates to:
  /// **'El servicio de precios de carburantes no respondió correctamente (código {code}). Inténtalo de nuevo en unos minutos.'**
  String fuelPriceServiceError(int code);

  /// No description provided for @routingKeyInvalid.
  ///
  /// In es, this message translates to:
  /// **'La clave de OpenRouteService no es válida o no está configurada.'**
  String get routingKeyInvalid;

  /// No description provided for @routingRateLimited.
  ///
  /// In es, this message translates to:
  /// **'Se ha superado el límite de peticiones de rutas por hoy. Inténtalo más tarde.'**
  String get routingRateLimited;

  /// No description provided for @routingGenericErrorWithMessage.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido calcular la ruta: {message}'**
  String routingGenericErrorWithMessage(String message);

  /// No description provided for @routingGenericErrorWithCode.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido calcular la ruta (código {code}). Inténtalo de nuevo.'**
  String routingGenericErrorWithCode(int code);

  /// No description provided for @routingNoRoute.
  ///
  /// In es, this message translates to:
  /// **'No se ha encontrado una ruta en coche hasta esa gasolinera.'**
  String get routingNoRoute;

  /// No description provided for @locationGpsDisabled.
  ///
  /// In es, this message translates to:
  /// **'El GPS está desactivado. Actívalo en los ajustes del teléfono para poder buscar gasolineras cerca de ti.'**
  String get locationGpsDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Necesito permiso de ubicación para encontrar gasolineras cerca de ti. También puedes elegir tu provincia manualmente.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionBlocked.
  ///
  /// In es, this message translates to:
  /// **'El permiso de ubicación está bloqueado para esta app. Actívalo desde los ajustes del sistema, o elige tu provincia manualmente.'**
  String get locationPermissionBlocked;

  /// No description provided for @priceAlertChannelName.
  ///
  /// In es, this message translates to:
  /// **'Cambios de precio'**
  String get priceAlertChannelName;

  /// No description provided for @priceAlertChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Avisa cuando sube o baja el precio de una gasolinera favorita'**
  String get priceAlertChannelDesc;

  /// No description provided for @priceAlertDropTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Bajó el precio en {brand}!'**
  String priceAlertDropTitle(String brand);

  /// No description provided for @priceAlertRiseTitle.
  ///
  /// In es, this message translates to:
  /// **'Subió el precio en {brand}'**
  String priceAlertRiseTitle(String brand);

  /// No description provided for @priceAlertBody.
  ///
  /// In es, this message translates to:
  /// **'Ahora a {newPrice} € (antes {oldPrice} €)'**
  String priceAlertBody(String newPrice, String oldPrice);

  /// No description provided for @priceAlertFallbackBrand.
  ///
  /// In es, this message translates to:
  /// **'tu favorita'**
  String get priceAlertFallbackBrand;

  /// No description provided for @fuelGasolina95.
  ///
  /// In es, this message translates to:
  /// **'Gasolina 95'**
  String get fuelGasolina95;

  /// No description provided for @fuelGasolina98.
  ///
  /// In es, this message translates to:
  /// **'Gasolina 98'**
  String get fuelGasolina98;

  /// No description provided for @fuelGasoleoA.
  ///
  /// In es, this message translates to:
  /// **'Diésel (Gasóleo A)'**
  String get fuelGasoleoA;

  /// No description provided for @fuelGasoleoPremium.
  ///
  /// In es, this message translates to:
  /// **'Diésel Premium'**
  String get fuelGasoleoPremium;

  /// No description provided for @fuelGlp.
  ///
  /// In es, this message translates to:
  /// **'GLP (Autogás)'**
  String get fuelGlp;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In es, this message translates to:
  /// **'Idioma del sistema'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In es, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @fuelLogTitle.
  ///
  /// In es, this message translates to:
  /// **'Consumo y gastos'**
  String get fuelLogTitle;

  /// No description provided for @fuelLogAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Añadir repostaje'**
  String get fuelLogAddTooltip;

  /// No description provided for @fuelLogFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo repostaje'**
  String get fuelLogFormTitle;

  /// No description provided for @fuelLogFormFuelType.
  ///
  /// In es, this message translates to:
  /// **'Combustible'**
  String get fuelLogFormFuelType;

  /// No description provided for @fuelLogFormLiters.
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get fuelLogFormLiters;

  /// No description provided for @fuelLogFormPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio total (€)'**
  String get fuelLogFormPrice;

  /// No description provided for @fuelLogFormKm.
  ///
  /// In es, this message translates to:
  /// **'Km recorridos desde el último repostaje'**
  String get fuelLogFormKm;

  /// No description provided for @fuelLogFormSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar repostaje'**
  String get fuelLogFormSave;

  /// No description provided for @fuelLogValidationRequired.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio'**
  String get fuelLogValidationRequired;

  /// No description provided for @fuelLogValidationNumber.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido'**
  String get fuelLogValidationNumber;

  /// No description provided for @fuelLogEmptyState.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado ningún repostaje. Añade el primero para empezar a ver tu consumo medio.'**
  String get fuelLogEmptyState;

  /// No description provided for @fuelLogAverageConsumption.
  ///
  /// In es, this message translates to:
  /// **'Consumo medio'**
  String get fuelLogAverageConsumption;

  /// No description provided for @fuelLogConsumptionUnit.
  ///
  /// In es, this message translates to:
  /// **'L/100km'**
  String get fuelLogConsumptionUnit;

  /// No description provided for @fuelLogTotalSpent.
  ///
  /// In es, this message translates to:
  /// **'Gastado en total'**
  String get fuelLogTotalSpent;

  /// No description provided for @fuelLogHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de repostajes'**
  String get fuelLogHistoryTitle;

  /// No description provided for @fuelLogEntrySubtitle.
  ///
  /// In es, this message translates to:
  /// **'{liters} L · {km} km · {price} €'**
  String fuelLogEntrySubtitle(String liters, String km, String price);

  /// No description provided for @fuelLogDeleteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar repostaje'**
  String get fuelLogDeleteTooltip;

  /// No description provided for @fuelLogRecommendationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones para ti'**
  String get fuelLogRecommendationsTitle;

  /// No description provided for @fuelLogRecommendationsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Registra un par de repostajes y algún trayecto navegado más para recibir recomendaciones personalizadas.'**
  String get fuelLogRecommendationsEmpty;

  /// No description provided for @recoConsumptionRising.
  ///
  /// In es, this message translates to:
  /// **'Tu consumo medio ha subido un {percent}% últimamente. Revisa la presión de los neumáticos y el filtro de aire: pueden estar disparando el gasto.'**
  String recoConsumptionRising(String percent);

  /// No description provided for @recoConsumptionImproving.
  ///
  /// In es, this message translates to:
  /// **'Tu consumo medio ha bajado un {percent}% respecto a tus repostajes anteriores. Vas por buen camino.'**
  String recoConsumptionImproving(String percent);

  /// No description provided for @recoHighSpeed.
  ///
  /// In es, this message translates to:
  /// **'Tu velocidad media en trayectos recientes ({speed} km/h) es alta. Reducir la velocidad en carretera puede bajar tu consumo notablemente.'**
  String recoHighSpeed(String speed);

  /// No description provided for @recoLowSpeedHighConsumption.
  ///
  /// In es, this message translates to:
  /// **'Tus trayectos recientes son cortos y a poca velocidad media ({speed} km/h), lo que suele disparar el consumo por ciudad. Si puedes, agrupa varios recados en un solo trayecto.'**
  String recoLowSpeedHighConsumption(String speed);

  /// No description provided for @recoAllGood.
  ///
  /// In es, this message translates to:
  /// **'Tu consumo y tu forma de conducir están dentro de lo normal. Sigue así.'**
  String get recoAllGood;

  /// No description provided for @fuelLogVehicleLabel.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get fuelLogVehicleLabel;

  /// No description provided for @fuelLogDefaultVehicleName.
  ///
  /// In es, this message translates to:
  /// **'Mi coche'**
  String get fuelLogDefaultVehicleName;

  /// No description provided for @fuelLogManageVehiclesTooltip.
  ///
  /// In es, this message translates to:
  /// **'Gestionar vehículos'**
  String get fuelLogManageVehiclesTooltip;

  /// No description provided for @fuelLogManageVehiclesTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus vehículos'**
  String get fuelLogManageVehiclesTitle;

  /// No description provided for @fuelLogAddVehicleHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del vehículo (p. ej. Coche, Moto)'**
  String get fuelLogAddVehicleHint;

  /// No description provided for @fuelLogAddVehicleButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get fuelLogAddVehicleButton;

  /// No description provided for @fuelLogDeleteVehicleTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar vehículo'**
  String get fuelLogDeleteVehicleTooltip;

  /// No description provided for @fuelLogCannotDeleteLastVehicle.
  ///
  /// In es, this message translates to:
  /// **'Tiene que quedar al menos un vehículo.'**
  String get fuelLogCannotDeleteLastVehicle;

  /// No description provided for @navEstimatedCost.
  ///
  /// In es, this message translates to:
  /// **'Coste estimado: {cost} €'**
  String navEstimatedCost(String cost);

  /// No description provided for @stationPriceTrendTitle.
  ///
  /// In es, this message translates to:
  /// **'Evolución de precio (favorita)'**
  String get stationPriceTrendTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
