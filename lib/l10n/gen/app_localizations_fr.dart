// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonGasStationFallback => 'Station-service';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get appTabHome => 'Recherche';

  @override
  String get appTabFuelLog => 'Consommation';

  @override
  String get appTabSettings => 'Réglages';

  @override
  String get homeHeadline => 'Trouve la station-service\nla moins chère';

  @override
  String get homeSubtitle =>
      'Compare les prix autour de toi et laisse-toi guider pas à pas, sans quitter l\'appli.';

  @override
  String get homeFavoritesTitle => 'Tes favorites';

  @override
  String get homeFavoritesEmptyHint =>
      'Appuie sur ⭐ sur une station pour l\'enregistrer ici et voir son prix sans la rechercher à chaque fois.';

  @override
  String get homeUseLocationButton => 'Utiliser ma position actuelle';

  @override
  String get homeUseLocationLoading => 'Recherche de ta position…';

  @override
  String get homeSearchByZoneDivider => 'OU RECHERCHER PAR ZONE';

  @override
  String get homeProvinceLabel => 'Choisis ta province';

  @override
  String get homeSearchProvinceButton => 'Rechercher dans cette province';

  @override
  String get homeErrorChooseProvince =>
      'Choisis d\'abord une province dans la liste.';

  @override
  String get homeFuelLogCardTitle => 'Consommation et dépenses';

  @override
  String get homeFuelLogCardSubtitle =>
      'Note tes pleins et consulte ta consommation moyenne';

  @override
  String get homeSettingsTooltip => 'Réglages';

  @override
  String get resultsTitleNearby => 'Près de toi';

  @override
  String get resultsListViewTooltip => 'Voir la liste';

  @override
  String get resultsMapViewTooltip => 'Voir la carte';

  @override
  String get resultsSearchHint => 'Rechercher une station, une rue, une ville…';

  @override
  String resultsFilteringChip(String query) {
    return 'Filtre : « $query »';
  }

  @override
  String get results24hFilter => 'Ouvert 24h/24';

  @override
  String get resultsMunicipalityLabel => 'Commune';

  @override
  String get resultsAllMunicipalities => 'Toutes les communes';

  @override
  String get resultsLocalityLabel => 'Localité';

  @override
  String get resultsAllLocalities => 'Toutes les localités';

  @override
  String get resultsCheapestLabel => 'La moins chère';

  @override
  String get resultsMostExpensiveLabel => 'La plus chère';

  @override
  String resultsNoMatchSearch(String query) {
    return 'Aucune station ne correspond à « $query » ici.';
  }

  @override
  String get resultsNo24h => 'Aucune station ouverte 24h/24 ici.';

  @override
  String resultsNoFuelType(String fuel) {
    return 'Aucune station ne vend du $fuel par ici.';
  }

  @override
  String get resultsNearbyTitle => 'Aussi près de toi';

  @override
  String get resultsNearbySubtitle =>
      'Il y a peu de stations dans ta localité ; celles-ci sont à moins de 20 km.';

  @override
  String navTitle(String brand) {
    return 'Vers $brand';
  }

  @override
  String get navGasStationFallback => 'la station-service';

  @override
  String get navRecalcTooltip => 'Recalculer l\'itinéraire';

  @override
  String get navOffRouteMessage => 'On dirait que tu as quitté l\'itinéraire';

  @override
  String get navRecalculate => 'Recalculer';

  @override
  String get navArrived => 'Tu es arrivé !';

  @override
  String get navBackToList => 'Retour à la liste';

  @override
  String get stationCheapestBadge => 'la moins chère';

  @override
  String get stationMostExpensiveBadge => 'la plus chère';

  @override
  String get stationRemoveFavoriteTooltip => 'Retirer des favorites';

  @override
  String get stationSaveFavoriteTooltip => 'Enregistrer en favorite';

  @override
  String get stationCalculatingRoute => 'Calcul de l\'itinéraire…';

  @override
  String get stationNavigateButton => 'Naviguer jusqu\'ici';

  @override
  String stationCheaperNearby(String brand, String savings, int liters) {
    return 'Il y en a une moins chère à proximité ($brand) : tu économises $savings € sur un plein de $liters L. Appuie pour la voir.';
  }

  @override
  String fuelPriceServiceError(int code) {
    return 'Le service des prix des carburants n\'a pas répondu correctement (code $code). Réessaie dans quelques minutes.';
  }

  @override
  String get routingKeyInvalid =>
      'La clé OpenRouteService est invalide ou absente.';

  @override
  String get routingRateLimited =>
      'Limite de requêtes d\'itinéraire atteinte pour aujourd\'hui. Réessaie plus tard.';

  @override
  String routingGenericErrorWithMessage(String message) {
    return 'Impossible de calculer l\'itinéraire : $message';
  }

  @override
  String routingGenericErrorWithCode(int code) {
    return 'Impossible de calculer l\'itinéraire (code $code). Réessaie.';
  }

  @override
  String get routingNoRoute =>
      'Aucun itinéraire en voiture trouvé jusqu\'à cette station.';

  @override
  String get locationGpsDisabled =>
      'Le GPS est désactivé. Active-le dans les réglages du téléphone pour rechercher des stations à proximité.';

  @override
  String get locationPermissionDenied =>
      'J\'ai besoin de la localisation pour trouver des stations près de toi. Tu peux aussi choisir ta province manuellement.';

  @override
  String get locationPermissionBlocked =>
      'La localisation est bloquée pour cette application. Active-la dans les réglages système, ou choisis ta province manuellement.';

  @override
  String get priceAlertChannelName => 'Changements de prix';

  @override
  String get priceAlertChannelDesc =>
      'Te prévient quand le prix d\'une station favorite augmente ou baisse';

  @override
  String priceAlertDropTitle(String brand) {
    return 'Le prix a baissé chez $brand !';
  }

  @override
  String priceAlertRiseTitle(String brand) {
    return 'Le prix a augmenté chez $brand';
  }

  @override
  String priceAlertBody(String newPrice, String oldPrice) {
    return 'Maintenant à $newPrice € (avant $oldPrice €)';
  }

  @override
  String get priceAlertFallbackBrand => 'ta favorite';

  @override
  String get fuelGasolina95 => 'Essence 95';

  @override
  String get fuelGasolina98 => 'Essence 98';

  @override
  String get fuelGasoleoA => 'Diesel';

  @override
  String get fuelGasoleoPremium => 'Diesel premium';

  @override
  String get fuelGlp => 'GPL';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsLanguageLabel => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du système';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get fuelLogTitle => 'Consommation et dépenses';

  @override
  String get fuelLogAddTooltip => 'Ajouter un plein';

  @override
  String get fuelLogFormTitle => 'Nouveau plein';

  @override
  String get fuelLogFormFuelType => 'Carburant';

  @override
  String get fuelLogFormLiters => 'Litres';

  @override
  String get fuelLogFormPrice => 'Prix total (€)';

  @override
  String get fuelLogFormKm => 'Km parcourus depuis le dernier plein';

  @override
  String get fuelLogFormSave => 'Enregistrer le plein';

  @override
  String get fuelLogValidationRequired => 'Obligatoire';

  @override
  String get fuelLogValidationNumber => 'Saisis un nombre valide';

  @override
  String get fuelLogEmptyState =>
      'Aucun plein enregistré pour l\'instant. Ajoute le premier pour voir ta consommation moyenne.';

  @override
  String get fuelLogAverageConsumption => 'Consommation moyenne';

  @override
  String get fuelLogConsumptionUnit => 'L/100km';

  @override
  String get fuelLogTotalSpent => 'Total dépensé';

  @override
  String get fuelLogHistoryTitle => 'Historique des pleins';

  @override
  String fuelLogEntrySubtitle(String liters, String km, String price) {
    return '$liters L · $km km · $price €';
  }

  @override
  String get fuelLogDeleteTooltip => 'Supprimer le plein';

  @override
  String get fuelLogRecommendationsTitle => 'Recommandations pour toi';

  @override
  String get fuelLogRecommendationsEmpty =>
      'Enregistre encore quelques pleins et trajets pour recevoir des recommandations personnalisées.';

  @override
  String recoConsumptionRising(String percent) {
    return 'Ta consommation moyenne a augmenté de $percent % dernièrement. Vérifie la pression des pneus et le filtre à air : ils peuvent faire grimper la facture.';
  }

  @override
  String recoConsumptionImproving(String percent) {
    return 'Ta consommation moyenne a baissé de $percent % par rapport à tes pleins précédents. Tu es sur la bonne voie.';
  }

  @override
  String recoHighSpeed(String speed) {
    return 'Ta vitesse moyenne sur tes derniers trajets ($speed km/h) est élevée. Ralentir sur la route peut nettement réduire ta consommation.';
  }

  @override
  String recoLowSpeedHighConsumption(String speed) {
    return 'Tes derniers trajets sont courts et à faible vitesse moyenne ($speed km/h), ce qui fait souvent grimper la consommation en ville. Regrouper tes courses en un seul trajet peut aider.';
  }

  @override
  String get recoAllGood =>
      'Ta consommation et ta façon de conduire sont dans la normale. Continue comme ça.';

  @override
  String get fuelLogVehicleLabel => 'Véhicule';

  @override
  String get fuelLogDefaultVehicleName => 'Ma voiture';

  @override
  String get fuelLogManageVehiclesTooltip => 'Gérer les véhicules';

  @override
  String get fuelLogManageVehiclesTitle => 'Tes véhicules';

  @override
  String get fuelLogAddVehicleHint => 'Nom du véhicule (ex. Voiture, Moto)';

  @override
  String get fuelLogAddVehicleButton => 'Ajouter';

  @override
  String get fuelLogDeleteVehicleTooltip => 'Supprimer le véhicule';

  @override
  String get fuelLogCannotDeleteLastVehicle =>
      'Il doit rester au moins un véhicule.';

  @override
  String navEstimatedCost(String cost) {
    return 'Coût estimé : $cost €';
  }

  @override
  String get stationPriceTrendTitle => 'Évolution du prix (favorite)';
}
