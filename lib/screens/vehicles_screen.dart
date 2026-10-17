import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';
import '../models/fuel_log_entry.dart';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import '../services/fuel_log_service.dart';
import '../services/vehicle_service.dart';
import '../theme/app_theme.dart';

/// Totales de un vehículo (litros, gasto, número de repostajes), a partir
/// de su historial de "Consumo y gastos".
class _VehicleStats {
  const _VehicleStats({
    required this.liters,
    required this.spent,
    required this.count,
  });

  final double liters;
  final double spent;
  final int count;

  static _VehicleStats from(List<FuelLogEntry> entries) {
    if (entries.isEmpty) return const _VehicleStats(liters: 0, spent: 0, count: 0);
    return _VehicleStats(
      liters: entries.fold(0.0, (sum, e) => sum + e.liters),
      spent: entries.fold(0.0, (sum, e) => sum + e.totalPrice),
      count: entries.length,
    );
  }
}

/// Pantalla "Mis vehículos": todos los coches/motos del usuario, con un
/// icono según su tipo y cuánto llevan gastado en total, para llevar un
/// registro aparte del detalle de "Consumo y gastos" por vehículo.
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _vehicleService = VehicleService();
  final _fuelLogService = FuelLogService();

  List<Vehicle> _vehicles = [];
  Map<String, _VehicleStats> _stats = {};
  String? _activeVehicleId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles = await _vehicleService.getVehicles();
    final activeId = await _vehicleService.getActiveVehicleId();
    final entries = await _fuelLogService.getEntries();
    final stats = <String, _VehicleStats>{
      for (final v in vehicles)
        v.id: _VehicleStats.from(entries.where((e) => e.vehicleId == v.id).toList()),
    };
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _activeVehicleId = activeId;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _setActive(String id) async {
    await _vehicleService.setActiveVehicleId(id);
    if (mounted) setState(() => _activeVehicleId = id);
  }

  Future<void> _deleteVehicle(String id) async {
    if (_vehicles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.fuelLogCannotDeleteLastVehicle)),
      );
      return;
    }
    await _vehicleService.deleteVehicle(id);
    await _load();
  }

  Future<void> _addVehicle() async {
    final result = await showModalBottomSheet<(String, VehicleType)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddVehicleSheet(),
    );
    if (result == null) return;
    final (name, type) = result;
    await _vehicleService.addVehicle(Vehicle(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      type: type,
    ));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vehiclesScreenTitle),
        actions: [
          IconButton(
            onPressed: _addVehicle,
            tooltip: l10n.vehiclesScreenAddTooltip,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                final stats = _stats[vehicle.id] ??
                    const _VehicleStats(liters: 0, spent: 0, count: 0);
                final isActive = vehicle.id == _activeVehicleId;
                final name = vehicle.name.isEmpty
                    ? l10n.fuelLogDefaultVehicleName
                    : vehicle.name;

                return Material(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _setActive(vehicle.id),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: isActive ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(vehicle.type.icon,
                                color: colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, fontSize: 15.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          l10n.vehiclesScreenActiveLabel,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vehicle.type.labelFor(l10n),
                                  style: TextStyle(
                                      fontSize: 12, color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  stats.count == 0
                                      ? l10n.vehiclesScreenNoFillUps
                                      : l10n.vehiclesScreenStatsLine(
                                          stats.count,
                                          stats.liters.toStringAsFixed(1),
                                          stats.spent.toStringAsFixed(2),
                                        ),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.cheapestColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _vehicles.length > 1
                                ? () => _deleteVehicle(vehicle.id)
                                : null,
                            tooltip: l10n.fuelLogDeleteVehicleTooltip,
                            icon: Icon(Icons.delete_outline_rounded,
                                color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  const _AddVehicleSheet();

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _nameController = TextEditingController();
  VehicleType _type = VehicleType.car;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name, _type));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.vehiclesFormAddTitle,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l10n.vehiclesFormNameHint),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.vehiclesFormTypeLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: VehicleType.values.map((type) {
                final selected = type == _type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: selected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _type = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                type.icon,
                                color: selected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.labelFor(l10n),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.vehiclesFormSave),
            ),
          ],
        ),
      ),
    );
  }
}
