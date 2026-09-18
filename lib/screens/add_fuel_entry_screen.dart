import 'package:flutter/material.dart';

import '../models/fuel_log_entry.dart';
import '../models/fuel_type.dart';

const _mesesLargos = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String formatFecha(DateTime d) => '${d.day} de ${_mesesLargos[d.month - 1]} de ${d.year}';

/// Formulario para apuntar un repostaje nuevo en el diario.
class AddFuelEntryScreen extends StatefulWidget {
  const AddFuelEntryScreen({super.key});

  @override
  State<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends State<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();

  DateTime _date = DateTime.now();
  FuelType _fuelType = FuelType.gasolina95;
  bool _fullTank = true;

  @override
  void dispose() {
    _litersController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final liters = double.parse(_litersController.text.replaceAll(',', '.'));
    final cost = double.parse(_costController.text.replaceAll(',', '.'));
    final odometerText = _odometerController.text.trim();
    final odometer =
        odometerText.isEmpty ? null : double.parse(odometerText.replaceAll(',', '.'));

    final entry = FuelLogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: _date,
      fuelType: _fuelType,
      liters: liters,
      totalCost: cost,
      odometerKm: odometer,
      fullTank: _fullTank,
    );
    Navigator.of(context).pop(entry);
  }

  String? _positiveNumber(String? value, {required String campo}) {
    if (value == null || value.trim().isEmpty) return 'Escribe $campo';
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Escribe un número válido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo repostaje')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_rounded),
                label: Text(formatFecha(_date)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FuelType>(
                initialValue: _fuelType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Combustible',
                  prefixIcon: Icon(Icons.local_gas_station_rounded),
                ),
                items: FuelType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (t) => setState(() => _fuelType = t!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litersController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Litros repostados',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                  suffixText: 'L',
                ),
                validator: (v) => _positiveNumber(v, campo: 'los litros'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio total pagado',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: '€',
                ),
                validator: (v) => _positiveNumber(v, campo: 'el precio'),
                onChanged: (_) => setState(() {}),
              ),
              if (_litersController.text.trim().isNotEmpty &&
                  double.tryParse(_litersController.text.trim().replaceAll(',', '.')) != null &&
                  double.tryParse(_litersController.text.trim().replaceAll(',', '.'))! > 0 &&
                  _costController.text.trim().isNotEmpty &&
                  double.tryParse(_costController.text.trim().replaceAll(',', '.')) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    '≈ ${(double.parse(_costController.text.trim().replaceAll(',', '.')) / double.parse(_litersController.text.trim().replaceAll(',', '.'))).toStringAsFixed(3)} €/L',
                    style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _odometerController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Kilómetros del cuentakilómetros (opcional)',
                  prefixIcon: Icon(Icons.speed_rounded),
                  suffixText: 'km',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Escribe un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _fullTank,
                onChanged: (v) => setState(() => _fullTank = v),
                contentPadding: EdgeInsets.zero,
                title: const Text('Depósito lleno'),
                subtitle: const Text(
                  'Actívalo si has llenado del todo. Hace falta para poder '
                  'calcular tu consumo medio.',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Guardar repostaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
