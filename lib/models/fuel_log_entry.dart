import '../models/fuel_type.dart';

/// Un repostaje registrado a mano por el usuario, para llevar el gasto y
/// calcular el consumo medio del coche.
class FuelLogEntry {
  FuelLogEntry({
    required this.id,
    required this.date,
    required this.fuelType,
    required this.liters,
    required this.totalPrice,
    required this.kmSinceLast,
  });

  final String id;
  final DateTime date;
  final FuelType fuelType;
  final double liters;
  final double totalPrice;

  /// Kilómetros recorridos desde el repostaje anterior (dato que introduce
  /// el propio usuario, no viene del cuentakilómetros del coche).
  final double kmSinceLast;

  /// Litros consumidos cada 100 km, a partir de los km declarados desde el
  /// repostaje anterior. `null` si no hay km (p. ej. el primer repostaje).
  double? get consumptionL100km =>
      kmSinceLast > 0 ? (liters / kmSinceLast) * 100 : null;

  double get pricePerLiter => liters > 0 ? totalPrice / liters : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'fuelType': fuelType.name,
        'liters': liters,
        'totalPrice': totalPrice,
        'kmSinceLast': kmSinceLast,
      };

  factory FuelLogEntry.fromJson(Map<String, dynamic> json) => FuelLogEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        fuelType: FuelType.values.firstWhere(
          (t) => t.name == json['fuelType'],
          orElse: () => FuelType.gasolina95,
        ),
        liters: (json['liters'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        kmSinceLast: (json['kmSinceLast'] as num).toDouble(),
      );
}
