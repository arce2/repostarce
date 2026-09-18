import 'package:flutter/material.dart';

import '../models/fuel_log_entry.dart';
import '../services/fuel_log_service.dart';
import '../theme/app_theme.dart';
import 'add_fuel_entry_screen.dart';

const _mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];
const _mesesLargosNominativo = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// Diario de repostajes: gasto de este mes, consumo medio y el historial
/// completo de lo que el usuario ha ido apuntando.
class FuelLogScreen extends StatefulWidget {
  const FuelLogScreen({super.key});

  @override
  State<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends State<FuelLogScreen> {
  final _service = FuelLogService();
  List<FuelLogEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.getEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _addEntry() async {
    final entry = await Navigator.of(context).push<FuelLogEntry>(
      MaterialPageRoute(builder: (_) => const AddFuelEntryScreen()),
    );
    if (entry == null) return;
    await _service.addEntry(entry);
    _load();
  }

  Future<void> _deleteEntry(FuelLogEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Borrar este repostaje?'),
        content: Text(
          '${entry.liters.toStringAsFixed(1)} L el ${entry.date.day} de '
          '${_mesesLargosNominativo[entry.date.month - 1]}. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _service.deleteEntry(entry.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final monthSpend = _service.totalSpentInMonth(_entries, now);
    final avgConsumption = _service.averageConsumptionL100km(_entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis repostajes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Repostaje'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_month_rounded,
                          label: 'Gasto en ${_mesesLargosNominativo[now.month - 1]}',
                          value: '${monthSpend.toStringAsFixed(2)} €',
                          color: AppTheme.cheapestColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.speed_rounded,
                          label: 'Consumo medio',
                          value: avgConsumption != null
                              ? '${avgConsumption.toStringAsFixed(1)} L/100km'
                              : '—',
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (avgConsumption == null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 20, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Apunta al menos dos repostajes con depósito '
                              'lleno y kilometraje para ver tu consumo medio.',
                              style: TextStyle(
                                  fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 40, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no has apuntado ningún repostaje.\n'
                            'Pulsa "Repostaje" para añadir el primero.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _EntryTile(
                            entry: e,
                            onDelete: () => _deleteEntry(e),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onDelete});

  final FuelLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final d = entry.date;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${d.day}\n${_mesesCortos[d.month - 1]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.liters.toStringAsFixed(1)} L · ${entry.fuelType.label}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.pricePerLiter.toStringAsFixed(3)} €/L'
                  '${entry.odometerKm != null ? ' · ${entry.odometerKm!.toStringAsFixed(0)} km' : ''}'
                  '${!entry.fullTank ? ' · parcial' : ''}',
                  style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '${entry.totalCost.toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onSurfaceVariant),
            onPressed: onDelete,
            tooltip: 'Borrar',
          ),
        ],
      ),
    );
  }
}
