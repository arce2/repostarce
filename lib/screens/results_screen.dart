import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../models/fuel_type.dart';
import '../models/gas_station.dart';
import '../models/province.dart';
import '../services/fuel_price_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/map_markers.dart';
import '../widgets/station_detail_sheet.dart';
import '../widgets/station_list_tile.dart';
import 'navigation_screen.dart';

/// Lista + mapa de gasolineras, ordenadas por precio del combustible
/// elegido. Se puede llegar aquí desde el GPS o desde una provincia
/// elegida a mano en [HomeScreen].
class ResultsScreen extends StatefulWidget {
  const ResultsScreen._({this.origin, this.province});

  factory ResultsScreen.fromLocation(LatLng origin) =>
      ResultsScreen._(origin: origin);

  factory ResultsScreen.fromProvince(Province province) =>
      ResultsScreen._(province: province);

  /// Punto GPS de partida (modo "usar mi ubicación").
  final LatLng? origin;

  /// Provincia elegida a mano (modo alternativo, sin GPS).
  final Province? province;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _fuelService = FuelPriceService();
  final _locationService = LocationService();
  final _mapController = MapController();

  List<GasStation> _stations = [];
  bool _loading = true;
  String? _error;
  FuelType _selectedFuel = FuelType.gasolina95;
  bool _showMap = true;
  String? _selectedMunicipality;
  String? _selectedLocality;

  /// Texto buscado y confirmado con Enter/intro, que filtra el mapa y la
  /// lista por marca. Distinto de las sugerencias del buscador (que se
  /// muestran mientras se escribe, sobre todas las gasolineras).
  String? _searchFilter;

  /// Si está activo, solo se muestran gasolineras abiertas 24 horas.
  bool _only24h = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedMunicipality = null;
      _selectedLocality = null;
      _searchFilter = null;
      _only24h = false;
    });
    try {
      final stations = widget.origin != null
          ? await _fuelService.findNearby(
              lat: widget.origin!.latitude,
              lng: widget.origin!.longitude,
            )
          : await _fuelService.findByProvince(widget.province!.id);
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Municipios presentes en los resultados de la provincia actual, para el
  /// filtro manual (solo tiene sentido en modo provincia, donde puede haber
  /// decenas de municipios distintos).
  List<String> get _municipalities {
    final set = _stations
        .map((s) => s.municipality)
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  List<GasStation> get _municipalityFiltered {
    if (_selectedMunicipality == null) return _stations;
    return _stations
        .where((s) => s.municipality == _selectedMunicipality)
        .toList();
  }

  /// Pueblos/pedanías (campo `Localidad` de la API) dentro del municipio
  /// elegido. Un municipio puede agrupar varias localidades (p.ej. Murcia
  /// incluye Beniaján, Torreagüera, etc.), así que este filtro solo tiene
  /// sentido una vez elegido un municipio.
  List<String> get _localities {
    if (_selectedMunicipality == null) return const [];
    final set = _municipalityFiltered
        .map((s) => s.locality)
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  List<GasStation> get _localityFiltered {
    if (_selectedLocality == null) return _municipalityFiltered;
    return _municipalityFiltered
        .where((s) => s.locality == _selectedLocality)
        .toList();
  }

  /// Resultado final tras aplicar, además de municipio/localidad, el texto
  /// buscado con Enter (coincide con marca, dirección, municipio o
  /// localidad, igual que las sugerencias del buscador).
  List<GasStation> get _searchFiltered {
    final query = _searchFilter;
    if (query == null || query.isEmpty) return _localityFiltered;
    return _localityFiltered
        .where((s) =>
            s.brand.toLowerCase().contains(query) ||
            s.address.toLowerCase().contains(query) ||
            s.municipality.toLowerCase().contains(query) ||
            s.locality.toLowerCase().contains(query))
        .toList();
  }

  /// Resultado final tras aplicar también el filtro de "abierto 24h".
  List<GasStation> get _finalFiltered {
    if (!_only24h) return _searchFiltered;
    return _searchFiltered.where((s) => s.isOpen24h).toList();
  }

  List<GasStation> get _sorted =>
      _fuelService.sortedByPrice(_finalFiltered, _selectedFuel);

  LatLng get _mapCenter {
    if (widget.origin != null) return widget.origin!;
    final withCoords = _finalFiltered;
    if (withCoords.isEmpty) return const LatLng(40.4168, -3.7038); // Madrid
    final avgLat =
        withCoords.map((s) => s.latitude).reduce((a, b) => a + b) /
            withCoords.length;
    final avgLng =
        withCoords.map((s) => s.longitude).reduce((a, b) => a + b) /
            withCoords.length;
    return LatLng(avgLat, avgLng);
  }

  /// Zoom adecuado según cómo de acotada esté la zona actual: cuanto más
  /// concreto el filtro (localidad > municipio > provincia entera), más
  /// cerca. En modo GPS se mantiene el zoom original de "cerca de ti".
  double get _targetZoom {
    if (widget.origin != null) return 13;
    if (_selectedLocality != null) return 14;
    if (_selectedMunicipality != null) return 12;
    return 11;
  }

  /// Mueve el mapa ya visible a la zona actual (tras elegir municipio,
  /// localidad, buscar o cambiar el filtro 24h). El propio `initialCenter`
  /// de [FlutterMap] solo aplica la primera vez que se crea el widget, así
  /// que hay que recentrar a mano cuando cambian los filtros con el mapa
  /// ya abierto.
  void _recenterMap() {
    if (!_showMap) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_showMap) return;
      try {
        _mapController.move(_mapCenter, _targetZoom);
      } catch (_) {
        // El controlador todavía no está asociado a un mapa visible.
      }
    });
  }

  Future<void> _startNavigation(GasStation station) async {
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NavigationScreen(
        origin: LatLng(position.latitude, position.longitude),
        station: station,
      ),
    ));
  }

  void _openDetails(GasStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StationDetailSheet(
        station: station,
        highlightedFuel: _selectedFuel,
        fuelService: _fuelService,
        onNavigate: () => _startNavigation(station),
        onViewStation: _openDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    final cheapestId = sorted.isNotEmpty ? sorted.first.id : null;
    // Solo tiene sentido marcar "la más cara" si hay más de una estación:
    // con una sola, sería la misma que "la más barata".
    final mostExpensiveId = sorted.length > 1 ? sorted.last.id : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.province?.name ?? 'Cerca de ti'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list_rounded : Icons.map_rounded),
            tooltip: _showMap ? 'Ver lista' : 'Ver mapa',
            onPressed: () {
              setState(() => _showMap = !_showMap);
              _recenterMap();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _StationSearchField(
              stations: _stations,
              fuelType: _selectedFuel,
              onSelected: _openDetails,
              onSubmittedQuery: (query) {
                setState(() {
                  final trimmed = query.trim().toLowerCase();
                  _searchFilter = trimmed.isEmpty ? null : trimmed;
                });
                _recenterMap();
              },
            ),
          ),
          if (_searchFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  avatar: const Icon(Icons.filter_alt_rounded, size: 18),
                  label: Text('Filtrando: "$_searchFilter"'),
                  onDeleted: () {
                    setState(() => _searchFilter = null);
                    _recenterMap();
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: FuelType.values.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == FuelType.values.length) {
                    return FilterChip(
                      label: const Text('Abierto 24h'),
                      selected: _only24h,
                      showCheckmark: false,
                      avatar: Icon(
                        Icons.nightlight_round,
                        size: 16,
                        color: _only24h
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (v) {
                        setState(() => _only24h = v);
                        _recenterMap();
                      },
                    );
                  }
                  final type = FuelType.values[i];
                  final selected = _selectedFuel == type;
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: selected,
                    showCheckmark: false,
                    avatar: selected
                        ? Icon(Icons.check_rounded,
                            size: 18, color: colorScheme.onPrimaryContainer)
                        : null,
                    onSelected: (_) => setState(() => _selectedFuel = type),
                  );
                },
              ),
            ),
          ),
          if (widget.province != null && _municipalities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedMunicipality,
                isDense: true,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Municipio',
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos los municipios', overflow: TextOverflow.ellipsis),
                  ),
                  ..._municipalities.map(
                    (m) => DropdownMenuItem<String?>(
                      value: m,
                      child: Text(m, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (m) {
                  setState(() {
                    _selectedMunicipality = m;
                    _selectedLocality = null;
                  });
                  _recenterMap();
                },
              ),
            ),
          if (_selectedMunicipality != null && _localities.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DropdownButtonFormField<String?>(
                initialValue: _selectedLocality,
                isDense: true,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Localidad',
                  prefixIcon: Icon(Icons.holiday_village_rounded),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos los pueblos', overflow: TextOverflow.ellipsis),
                  ),
                  ..._localities.map(
                    (l) => DropdownMenuItem<String?>(
                      value: l,
                      child: Text(l, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (l) {
                  setState(() => _selectedLocality = l);
                  _recenterMap();
                },
              ),
            ),
          Expanded(child: _buildBody(sorted, cheapestId, mostExpensiveId)),
        ],
      ),
    );
  }

  Widget _buildBody(
    List<GasStation> sorted,
    String? cheapestId,
    String? mostExpensiveId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (sorted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 40, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                _searchFilter != null
                    ? 'Ninguna gasolinera coincide con "$_searchFilter" aquí.'
                    : _only24h
                        ? 'No hay gasolineras abiertas 24h aquí.'
                        : 'No hay gasolineras que vendan ${_selectedFuel.label} por aquí.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_showMap) {
      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: _targetZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fuel_finder',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  disableClusteringAtZoom: 16,
                  markers: [
                    for (final station in sorted)
                      Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: 38,
                        height: 38,
                        child: StationMarker(
                          isCheapest: station.id == cheapestId,
                          isMostExpensive: station.id == mostExpensiveId,
                          onTap: () => _openDetails(station),
                        ),
                      ),
                  ],
                  builder: (context, clusterMarkers) => _ClusterBubble(
                    count: clusterMarkers.length,
                  ),
                ),
              ),
              if (widget.origin != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.origin!,
                      width: 42,
                      height: 42,
                      child: const UserLocationDot(),
                    ),
                  ],
                ),
            ],
          ),
          if (mostExpensiveId != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _PriceExtremesRow(
                    cheapest: sorted.first,
                    mostExpensive: sorted.last,
                    fuelType: _selectedFuel,
                    onTapCheapest: () => _openDetails(sorted.first),
                    onTapMostExpensive: () => _openDetails(sorted.last),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        if (mostExpensiveId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: _PriceExtremesRow(
              cheapest: sorted.first,
              mostExpensive: sorted.last,
              fuelType: _selectedFuel,
              onTapCheapest: () => _openDetails(sorted.first),
              onTapMostExpensive: () => _openDetails(sorted.last),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final station = sorted[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StationListTile(
                  station: station,
                  fuelType: _selectedFuel,
                  isCheapest: station.id == cheapestId,
                  isMostExpensive: station.id == mostExpensiveId,
                  onTap: () => _openDetails(station),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Fila fija con las dos gasolineras destacadas (más barata / más cara) del
/// combustible elegido, para verlas sin tener que buscar en la lista.
/// Burbuja que agrupa varias gasolineras muy juntas en el mapa (si no, se
/// tapan unas a otras en zonas densas). Al tocarla, el propio paquete de
/// clustering hace zoom hasta separarlas.
class _ClusterBubble extends StatelessWidget {
  const _ClusterBubble({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _PriceExtremesRow extends StatelessWidget {
  const _PriceExtremesRow({
    required this.cheapest,
    required this.mostExpensive,
    required this.fuelType,
    required this.onTapCheapest,
    required this.onTapMostExpensive,
  });

  final GasStation cheapest;
  final GasStation mostExpensive;
  final FuelType fuelType;
  final VoidCallback onTapCheapest;
  final VoidCallback onTapMostExpensive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ExtremeCard(
            station: cheapest,
            fuelType: fuelType,
            label: 'Más barata',
            icon: Icons.star_rounded,
            color: AppTheme.cheapestColor,
            onTap: onTapCheapest,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ExtremeCard(
            station: mostExpensive,
            fuelType: fuelType,
            label: 'Más cara',
            icon: Icons.trending_up_rounded,
            color: AppTheme.mostExpensiveColor,
            onTap: onTapMostExpensive,
          ),
        ),
      ],
    );
  }
}

class _ExtremeCard extends StatelessWidget {
  const _ExtremeCard({
    required this.station,
    required this.fuelType,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final GasStation station;
  final FuelType fuelType;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = station.priceFor(fuelType);
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                station.brand.isNotEmpty ? station.brand : 'Gasolinera',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                price != null ? '${price.toStringAsFixed(3)} €' : '—',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Buscador con sugerencias: filtra por marca, dirección, municipio o
/// localidad mientras se escribe, mostrando el precio del combustible
/// elegido en cada sugerencia. Busca sobre todas las gasolineras cargadas,
/// sin tener en cuenta los filtros de municipio/localidad, para poder
/// encontrar una en concreto esté donde esté.
class _StationSearchField extends StatelessWidget {
  const _StationSearchField({
    required this.stations,
    required this.fuelType,
    required this.onSelected,
    required this.onSubmittedQuery,
  });

  final List<GasStation> stations;
  final FuelType fuelType;
  final ValueChanged<GasStation> onSelected;

  /// Se llama al pulsar Enter/intro en el teclado, con el texto tal cual
  /// está escrito en ese momento (para filtrar el mapa/lista por marca).
  final ValueChanged<String> onSubmittedQuery;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<GasStation>(
      displayStringForOption: (s) => s.brand.isNotEmpty ? s.brand : 'Gasolinera',
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<GasStation>.empty();
        return stations
            .where((s) =>
                s.brand.toLowerCase().contains(query) ||
                s.address.toLowerCase().contains(query) ||
                s.municipality.toLowerCase().contains(query) ||
                s.locality.toLowerCase().contains(query))
            .take(8);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: (text) {
            onFieldSubmitted();
            onSubmittedQuery(text);
            focusNode.unfocus();
          },
          decoration: const InputDecoration(
            hintText: 'Buscar gasolinera, calle o pueblo…',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
      },
      optionsViewBuilder: (context, onSelectedOption, options) {
        final colorScheme = Theme.of(context).colorScheme;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surfaceContainerLow,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 560),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, i) {
                  final station = options.elementAt(i);
                  final price = station.priceFor(fuelType);
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.local_gas_station_rounded,
                        color: colorScheme.primary),
                    title: Text(
                      station.brand.isNotEmpty ? station.brand : 'Gasolinera',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [station.address, station.municipality]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      price != null ? '${price.toStringAsFixed(3)} €' : '—',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => onSelectedOption(station),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: onSelected,
    );
  }
}
