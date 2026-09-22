import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/error_x.dart';
import '../l10n/l10n_x.dart';
import '../models/fuel_type.dart';
import '../models/gas_station.dart';
import '../models/province.dart';
import '../services/favorites_service.dart';
import '../services/fuel_price_service.dart';
import '../services/locale_service.dart';
import '../services/location_service.dart';
import '../services/price_alert_service.dart';
import '../services/price_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/station_detail_sheet.dart';
import '../widgets/station_list_tile.dart';
import 'fuel_log_screen.dart';
import 'navigation_screen.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

/// Pantalla de arranque: el usuario elige cómo quiere buscar gasolineras,
/// bien con su ubicación GPS, bien eligiendo su provincia a mano. Si tiene
/// gasolineras favoritas guardadas, se ven aquí mismo con su precio actual.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _locationService = LocationService();
  final _favoritesService = FavoritesService();
  final _fuelService = FuelPriceService();
  final _priceHistoryService = PriceHistoryService();
  final _priceAlertService = PriceAlertService();

  Province? _selectedProvince;
  bool _loadingLocation = false;
  String? _error;

  List<GasStation> _favoriteStations = [];
  bool _loadingFavorites = true;

  /// Precio del día distinto más reciente registrado para cada favorita
  /// (por id de gasolinera), para mostrar la tendencia ↑/↓.
  final Map<String, double?> _favoritePreviousPrices = {};

  /// Comprueba los precios de las favoritas cada pocos minutos mientras la
  /// app está abierta, además de al arrancar y al volver de segundo plano
  /// (ver [didChangeAppLifecycleState]), para detectar cambios sin tener
  /// que cerrar y volver a abrir la app.
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFavorites();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _loadFavorites(silent: true, forceRefresh: true),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavorites(silent: true, forceRefresh: true);
    }
  }

  Future<void> _loadFavorites({bool silent = false, bool forceRefresh = false}) async {
    if (!silent) setState(() => _loadingFavorites = true);
    try {
      if (forceRefresh) _fuelService.refresh();
      final ids = await _favoritesService.getFavoriteIds();
      final stations = await _fuelService.findByIds(ids);
      if (!mounted) return;
      setState(() {
        _favoriteStations = stations;
        _loadingFavorites = false;
      });
      await _updatePriceHistoryAndAlerts(stations);
    } catch (_) {
      // Sin conexión o fallo puntual: simplemente no mostramos favoritas
      // esta vez, no hace falta molestar con un error en la portada.
      if (!mounted) return;
      setState(() => _loadingFavorites = false);
    }
  }

  /// Registra el precio actual de cada favorita (para poder mostrar la
  /// tendencia ↑/↓) y avisa con una notificación si ha cambiado -subido o
  /// bajado- desde la última vez que se comprobó.
  Future<void> _updatePriceHistoryAndAlerts(List<GasStation> stations) async {
    for (final station in stations) {
      final fuelType = station.availableFuelTypes.isNotEmpty
          ? station.availableFuelTypes.first
          : FuelType.gasolina95;
      final price = station.priceFor(fuelType);
      if (price == null) continue;
      final previous = await _priceHistoryService.recordAndGetPrevious(
        station.id,
        fuelType,
        price,
      );
      if (mounted) {
        setState(() => _favoritePreviousPrices[station.id] = previous);
      }
      if (previous != null && (price - previous).abs() >= 0.001 && mounted) {
        await _priceAlertService.notifyPriceChange(
          l10n: context.l10n,
          stationId: station.id,
          brand: station.brand,
          oldPrice: previous,
          newPrice: price,
        );
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _error = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultsScreen.fromLocation(
          LatLng(position.latitude, position.longitude),
        ),
      ));
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        setState(() => _error = localizedErrorMessage(e, context.l10n));
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _searchByProvince() async {
    final province = _selectedProvince;
    if (province == null) {
      setState(() => _error = context.l10n.homeErrorChooseProvince);
      return;
    }
    setState(() => _error = null);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen.fromProvince(province),
    ));
    _loadFavorites();
  }

  Future<void> _startNavigationTo(GasStation station) async {
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NavigationScreen(
        origin: LatLng(position.latitude, position.longitude),
        station: station,
      ),
    ));
  }

  void _openFavoriteDetails(GasStation station) {
    final fuelType = station.availableFuelTypes.isNotEmpty
        ? station.availableFuelTypes.first
        : FuelType.gasolina95;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StationDetailSheet(
        station: station,
        highlightedFuel: fuelType,
        fuelService: _fuelService,
        onNavigate: () => _startNavigationTo(station),
        onViewStation: _openFavoriteDetails,
      ),
    ).then((_) => _loadFavorites());
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SettingsScreen(localeController: widget.localeController),
    ));
  }

  void _openFuelLog() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const FuelLogScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gasly'),
        actions: [
          IconButton(
            onPressed: _openSettings,
            tooltip: l10n.homeSettingsTooltip,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 220,
                        height: 220,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/icon/welcome_fox.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.homeHeadline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.homeSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _openFuelLog,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    color: colorScheme.onSecondaryContainer),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.homeFuelLogCardTitle,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                      Text(
                                        l10n.homeFuelLogCardSubtitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSecondaryContainer
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: colorScheme.onSecondaryContainer),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!_loadingFavorites) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 18, color: AppTheme.cheapestColor),
                            const SizedBox(width: 6),
                            Text(
                              l10n.homeFavoritesTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (!_loadingFavorites && _favoriteStations.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_outline_rounded,
                                  size: 20, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.homeFavoritesEmptyHint,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!_loadingFavorites && _favoriteStations.isNotEmpty)
                        ..._favoriteStations.map((station) {
                          final fuelType = station.availableFuelTypes.isNotEmpty
                              ? station.availableFuelTypes.first
                              : FuelType.gasolina95;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: StationListTile(
                              station: station,
                              fuelType: fuelType,
                              isCheapest: false,
                              previousPrice: _favoritePreviousPrices[station.id],
                              onTap: () => _openFavoriteDetails(station),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _loadingLocation ? null : _useCurrentLocation,
                        icon: _loadingLocation
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                        label: Text(_loadingLocation
                            ? l10n.homeUseLocationLoading
                            : l10n.homeUseLocationButton),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: colorScheme.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.homeSearchByZoneDivider,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: colorScheme.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<Province>(
                              initialValue: _selectedProvince,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.homeProvinceLabel,
                                prefixIcon: const Icon(Icons.map_outlined),
                              ),
                              items: Province.all
                                  .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.name,
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (p) =>
                                  setState(() => _selectedProvince = p),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _searchByProvince,
                              icon: const Icon(Icons.search_rounded),
                              label: Text(l10n.homeSearchProvinceButton),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  color: colorScheme.onErrorContainer, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(color: colorScheme.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
