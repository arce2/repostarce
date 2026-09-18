import 'fuel_type.dart';

/// Un repostaje apuntado a mano por el usuario: cuándo, cuánto combustible
/// y cuánto costó, con el kilometraje como dato opcional para poder
/// calcular el consumo medio.
class FuelLogEntry {
  FuelLogEntry({
    required this.id,
    required this.date,
    required this.fuelType,
    required this.liters,
    required this.totalCost,
    this.odometerKm,
    this.fullTank = true,
  });

  final String id;
  final DateTime date;
  final FuelType fuelType;
  final double liters;
  final double totalCost;

  /// Kilómetros totales del cuentakilómetros en el momento de repostar.
  /// Hace falta en dos repostajes consecutivos para calcular el consumo.
  final double? odometerKm;

  /// Si se llenó el depósito del todo. Los repostajes parciales no sirven
  /// para calcular el consumo de forma fiable, así que se excluyen de esa
  /// media (pero sí cuentan para el gasto).
  final bool fullTank;

  double get pricePerLiter => liters > 0 ? totalCost / liters : 0;

  factory FuelLogEntry.fromJson(Map<String, dynamic> json) => FuelLogEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        fuelType: FuelType.values.firstWhere(
          (t) => t.name == json['fuelType'],
          orElse: () => FuelType.gasolina95,
        ),
        liters: (json['liters'] as num).toDouble(),
        totalCost: (json['totalCost'] as num).toDouble(),
        odometerKm: (json['odometerKm'] as num?)?.toDouble(),
        fullTank: json['fullTank'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'fuelType': fuelType.name,
        'liters': liters,
        'totalCost': totalCost,
        'odometerKm': odometerKm,
        'fullTank': fullTank,
      };
}
