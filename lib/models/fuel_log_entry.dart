import '../models/fuel_type.dart';
import '../services/vehicle_service.dart';

/// Un repostaje registrado a mano por el usuario, para llevar el gasto y
/// calcular el consumo medio del vehículo.
class FuelLogEntry {
  FuelLogEntry({
    required this.id,
    required this.date,
    required this.fuelType,
    required this.liters,
    required this.totalPrice,
    required this.kmSinceLast,
    this.vehicleId = VehicleService.defaultVehicleId,
    this.invoiceNumber,
    this.issuerName,
    this.issuerTaxId,
    this.vatRatePercent,
  });

  final String id;
  final DateTime date;
  final FuelType fuelType;
  final double liters;
  final double totalPrice;

  /// Datos de facturación, opcionales: para quien quiera desgravar el
  /// repostaje como autónomo/empresa y necesite conservar estos datos de la
  /// factura o el ticket. `null` si no se rellenaron.
  final String? invoiceNumber;
  final String? issuerName;
  final String? issuerTaxId;

  /// % de IVA aplicado en la factura (en España, habitualmente 21% para
  /// combustible). Con este dato se puede calcular la base imponible y la
  /// cuota de IVA a partir del total pagado, sin tener que guardarlos aparte
  /// (y arriesgarse a que queden inconsistentes entre sí).
  final double? vatRatePercent;

  bool get hasInvoiceData =>
      invoiceNumber != null ||
      issuerName != null ||
      issuerTaxId != null ||
      vatRatePercent != null;

  double? get taxBase =>
      vatRatePercent != null ? totalPrice / (1 + vatRatePercent! / 100) : null;

  double? get vatAmount => taxBase != null ? totalPrice - taxBase! : null;

  /// A qué vehículo pertenece. Los repostajes guardados antes de que
  /// existieran varios vehículos no tienen este campo en el JSON, así que
  /// se les asigna el vehículo por defecto al leerlos (ver [fromJson]).
  final String vehicleId;

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
        'vehicleId': vehicleId,
        if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
        if (issuerName != null) 'issuerName': issuerName,
        if (issuerTaxId != null) 'issuerTaxId': issuerTaxId,
        if (vatRatePercent != null) 'vatRatePercent': vatRatePercent,
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
        vehicleId:
            json['vehicleId'] as String? ?? VehicleService.defaultVehicleId,
        invoiceNumber: json['invoiceNumber'] as String?,
        issuerName: json['issuerName'] as String?,
        issuerTaxId: json['issuerTaxId'] as String?,
        vatRatePercent: (json['vatRatePercent'] as num?)?.toDouble(),
      );
}
