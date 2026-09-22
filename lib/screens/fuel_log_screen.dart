import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../l10n/l10n_x.dart';
import '../models/fuel_log_entry.dart';
import '../models/fuel_type.dart';
import '../services/fuel_log_service.dart';
import '../services/recommendation_service.dart';
import '../theme/app_theme.dart';

/// Pantalla de "Consumo y gastos": registrar repostajes a mano, ver el
/// gasto total, el consumo medio (L/100km) y recomendaciones a partir de
/// ese consumo y de la velocidad media de los trayectos navegados.
class FuelLogScreen extends StatefulWidget {
  const FuelLogScreen({super.key});

  @override
  State<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends State<FuelLogScreen> {
  final _fuelLogService = FuelLogService();
  final _recommendationService = RecommendationService();

  List<FuelLogEntry> _entries = [];
  List<String> _recommendations = [];
  bool _loading = true;
  bool _initialLoadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context.l10n necesita Localizations.of(context), que no está
    // disponible todavía en initState(): se pide aquí, la primera vez que
    // las dependencias heredadas están listas.
    if (!_initialLoadStarted) {
      _initialLoadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    final l10n = context.l10n;
    final entries = await _fuelLogService.getEntries();
    final recommendations =
        await _recommendationService.buildRecommendations(l10n);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _recommendations = recommendations;
      _loading = false;
    });
  }

  Future<void> _deleteEntry(String id) async {
    await _fuelLogService.deleteEntry(id);
    _load();
  }

  Future<void> _openAddEntrySheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddFuelLogSheet(),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final avgConsumption = _fuelLogService.averageConsumption(_entries);
    final totalSpent = _fuelLogService.totalSpent(_entries);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fuelLogTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntrySheet,
        tooltip: l10n.fuelLogAddTooltip,
        child: const Icon(Icons.add_rounded),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _EmptyState(message: l10n.fuelLogEmptyState)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_gas_station_rounded,
                            label: l10n.fuelLogAverageConsumption,
                            value: avgConsumption != null
                                ? '${avgConsumption.toStringAsFixed(1)} ${l10n.fuelLogConsumptionUnit}'
                                : '—',
                            color: AppTheme.cheapestColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.payments_rounded,
                            label: l10n.fuelLogTotalSpent,
                            value: '${totalSpent.toStringAsFixed(2)} €',
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_rounded,
                            size: 18, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          l10n.fuelLogRecommendationsTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_recommendations.isEmpty)
                      _HintCard(text: l10n.fuelLogRecommendationsEmpty)
                    else
                      ..._recommendations.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecommendationCard(text: tip),
                          )),
                    const SizedBox(height: 20),
                    Text(
                      l10n.fuelLogHistoryTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FuelLogTile(
                            entry: entry,
                            onDelete: () => _deleteEntry(entry.id),
                          ),
                        )),
                  ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bolt_rounded, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_gas_station_outlined,
                size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _FuelLogTile extends StatelessWidget {
  const _FuelLogTile({required this.entry, required this.onDelete});

  final FuelLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final date = entry.date;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_gas_station_rounded,
                size: 20, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$dateLabel · ${entry.fuelType.labelFor(l10n)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(
                  l10n.fuelLogEntrySubtitle(
                    entry.liters.toStringAsFixed(1),
                    entry.kmSinceLast.toStringAsFixed(0),
                    entry.totalPrice.toStringAsFixed(2),
                  ),
                  style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: l10n.fuelLogDeleteTooltip,
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          ),
        ],
      ),
    );
  }
}

class _AddFuelLogSheet extends StatefulWidget {
  const _AddFuelLogSheet();

  @override
  State<_AddFuelLogSheet> createState() => _AddFuelLogSheetState();
}

class _AddFuelLogSheetState extends State<_AddFuelLogSheet> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _priceController = TextEditingController();
  final _kmController = TextEditingController();
  final _fuelLogService = FuelLogService();

  FuelType _fuelType = FuelType.gasolina95;
  bool _saving = false;

  @override
  void dispose() {
    _litersController.dispose();
    _priceController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final entry = FuelLogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      fuelType: _fuelType,
      liters: _parse(_litersController.text)!,
      totalPrice: _parse(_priceController.text)!,
      kmSinceLast: _parse(_kmController.text)!,
    );
    await _fuelLogService.addEntry(entry);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
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
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.fuelLogFormTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FuelType>(
                initialValue: _fuelType,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.fuelLogFormFuelType),
                items: FuelType.values
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t.labelFor(l10n))))
                    .toList(),
                onChanged: (v) => setState(() => _fuelType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _litersController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.fuelLogFormLiters),
                validator: (v) => _validateNumber(v, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.fuelLogFormPrice),
                validator: (v) => _validateNumber(v, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.fuelLogFormKm),
                validator: (v) => _validateNumber(v, l10n),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.fuelLogFormSave),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.fuelLogValidationRequired;
    final parsed = _parse(value);
    if (parsed == null || parsed <= 0) return l10n.fuelLogValidationNumber;
    return null;
  }
}
