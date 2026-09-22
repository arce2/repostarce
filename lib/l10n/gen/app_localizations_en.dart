// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonGasStationFallback => 'Gas station';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get appTabHome => 'Search';

  @override
  String get appTabFuelLog => 'Fuel log';

  @override
  String get appTabSettings => 'Settings';

  @override
  String get homeHeadline => 'Find the cheapest\ngas station';

  @override
  String get homeSubtitle =>
      'Compare prices nearby and we\'ll guide you there step by step, without leaving the app.';

  @override
  String get homeFavoritesTitle => 'Your favourites';

  @override
  String get homeFavoritesEmptyHint =>
      'Tap the ⭐ on any station to save it here and see its price without searching every time.';

  @override
  String get homeUseLocationButton => 'Use my current location';

  @override
  String get homeUseLocationLoading => 'Finding your location…';

  @override
  String get homeSearchByZoneDivider => 'OR SEARCH BY AREA';

  @override
  String get homeProvinceLabel => 'Choose your province';

  @override
  String get homeSearchProvinceButton => 'Search this province';

  @override
  String get homeErrorChooseProvince =>
      'Choose a province from the list first.';

  @override
  String get homeFuelLogCardTitle => 'Fuel log & expenses';

  @override
  String get homeFuelLogCardSubtitle =>
      'Log your fill-ups and check your average consumption';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get resultsTitleNearby => 'Near you';

  @override
  String get resultsListViewTooltip => 'Show list';

  @override
  String get resultsMapViewTooltip => 'Show map';

  @override
  String get resultsSearchHint => 'Search a station, street or town…';

  @override
  String resultsFilteringChip(String query) {
    return 'Filtering: \"$query\"';
  }

  @override
  String get results24hFilter => 'Open 24h';

  @override
  String get resultsMunicipalityLabel => 'Municipality';

  @override
  String get resultsAllMunicipalities => 'All municipalities';

  @override
  String get resultsLocalityLabel => 'Town';

  @override
  String get resultsAllLocalities => 'All towns';

  @override
  String get resultsCheapestLabel => 'Cheapest';

  @override
  String get resultsMostExpensiveLabel => 'Most expensive';

  @override
  String resultsNoMatchSearch(String query) {
    return 'No station matches \"$query\" here.';
  }

  @override
  String get resultsNo24h => 'No stations open 24h here.';

  @override
  String resultsNoFuelType(String fuel) {
    return 'No stations sell $fuel around here.';
  }

  @override
  String navTitle(String brand) {
    return 'To $brand';
  }

  @override
  String get navGasStationFallback => 'the gas station';

  @override
  String get navRecalcTooltip => 'Recalculate route';

  @override
  String get navOffRouteMessage => 'Looks like you\'ve left the route';

  @override
  String get navRecalculate => 'Recalculate';

  @override
  String get navArrived => 'You\'ve arrived!';

  @override
  String get navBackToList => 'Back to the list';

  @override
  String get stationCheapestBadge => 'cheapest';

  @override
  String get stationMostExpensiveBadge => 'most expensive';

  @override
  String get stationRemoveFavoriteTooltip => 'Remove from favourites';

  @override
  String get stationSaveFavoriteTooltip => 'Save as favourite';

  @override
  String get stationCalculatingRoute => 'Calculating route…';

  @override
  String get stationNavigateButton => 'Navigate here';

  @override
  String stationCheaperNearby(String brand, String savings, int liters) {
    return 'There\'s a cheaper one nearby ($brand): you save $savings € on a $liters L tank. Tap to view it.';
  }

  @override
  String fuelPriceServiceError(int code) {
    return 'The fuel price service didn\'t respond correctly (code $code). Try again in a few minutes.';
  }

  @override
  String get routingKeyInvalid =>
      'The OpenRouteService key is invalid or missing.';

  @override
  String get routingRateLimited =>
      'You\'ve hit today\'s routing request limit. Try again later.';

  @override
  String routingGenericErrorWithMessage(String message) {
    return 'Couldn\'t calculate the route: $message';
  }

  @override
  String routingGenericErrorWithCode(int code) {
    return 'Couldn\'t calculate the route (code $code). Try again.';
  }

  @override
  String get routingNoRoute => 'No driving route was found to that station.';

  @override
  String get locationGpsDisabled =>
      'GPS is turned off. Turn it on in your phone\'s settings to search for stations near you.';

  @override
  String get locationPermissionDenied =>
      'I need location permission to find stations near you. You can also choose your province manually.';

  @override
  String get locationPermissionBlocked =>
      'Location permission is blocked for this app. Enable it from system settings, or choose your province manually.';

  @override
  String get priceAlertChannelName => 'Price changes';

  @override
  String get priceAlertChannelDesc =>
      'Notifies you when a favourite station\'s price goes up or down';

  @override
  String priceAlertDropTitle(String brand) {
    return 'Price dropped at $brand!';
  }

  @override
  String priceAlertRiseTitle(String brand) {
    return 'Price went up at $brand';
  }

  @override
  String priceAlertBody(String newPrice, String oldPrice) {
    return 'Now $newPrice € (was $oldPrice €)';
  }

  @override
  String get priceAlertFallbackBrand => 'your favourite';

  @override
  String get fuelGasolina95 => 'Petrol 95';

  @override
  String get fuelGasolina98 => 'Petrol 98';

  @override
  String get fuelGasoleoA => 'Diesel';

  @override
  String get fuelGasoleoPremium => 'Premium diesel';

  @override
  String get fuelGlp => 'LPG (Autogas)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get fuelLogTitle => 'Fuel log & expenses';

  @override
  String get fuelLogAddTooltip => 'Add fill-up';

  @override
  String get fuelLogFormTitle => 'New fill-up';

  @override
  String get fuelLogFormFuelType => 'Fuel';

  @override
  String get fuelLogFormLiters => 'Litres';

  @override
  String get fuelLogFormPrice => 'Total price (€)';

  @override
  String get fuelLogFormKm => 'Km driven since last fill-up';

  @override
  String get fuelLogFormSave => 'Save fill-up';

  @override
  String get fuelLogValidationRequired => 'Required';

  @override
  String get fuelLogValidationNumber => 'Enter a valid number';

  @override
  String get fuelLogEmptyState =>
      'No fill-ups logged yet. Add your first one to start seeing your average consumption.';

  @override
  String get fuelLogAverageConsumption => 'Average consumption';

  @override
  String get fuelLogConsumptionUnit => 'L/100km';

  @override
  String get fuelLogTotalSpent => 'Total spent';

  @override
  String get fuelLogHistoryTitle => 'Fill-up history';

  @override
  String fuelLogEntrySubtitle(String liters, String km, String price) {
    return '$liters L · $km km · $price €';
  }

  @override
  String get fuelLogDeleteTooltip => 'Delete fill-up';

  @override
  String get fuelLogRecommendationsTitle => 'Recommendations for you';

  @override
  String get fuelLogRecommendationsEmpty =>
      'Log a couple more fill-ups and a navigated trip or two to get personalised recommendations.';

  @override
  String recoConsumptionRising(String percent) {
    return 'Your average consumption has risen $percent% lately. Check your tyre pressure and air filter: they could be driving up your spend.';
  }

  @override
  String recoConsumptionImproving(String percent) {
    return 'Your average consumption has dropped $percent% compared to earlier fill-ups. You\'re doing great.';
  }

  @override
  String recoHighSpeed(String speed) {
    return 'Your average speed on recent trips ($speed km/h) is high. Slowing down on the road can noticeably cut your consumption.';
  }

  @override
  String recoLowSpeedHighConsumption(String speed) {
    return 'Your recent trips are short and at a low average speed ($speed km/h), which tends to spike city consumption. Bundling errands into one trip can help if that\'s an option.';
  }

  @override
  String get recoAllGood =>
      'Your consumption and driving style are within the normal range. Keep it up.';
}
