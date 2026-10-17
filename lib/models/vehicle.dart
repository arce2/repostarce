import 'vehicle_type.dart';

/// Un vehículo del usuario, para poder llevar el consumo de varios coches
/// (o motos) por separado en vez de mezclarlos todos en una sola media.
class Vehicle {
  Vehicle({
    required this.id,
    required this.name,
    this.type = VehicleType.car,
    this.model = '',
    this.year,
  });

  final String id;
  final String name;
  final VehicleType type;

  /// Modelo (p. ej. "Seat Ibiza"). Cadena vacía si no se indicó.
  final String model;

  /// Año de matriculación/fabricación. `null` si no se indicó.
  final int? year;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'model': model,
        if (year != null) 'year': year,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        name: json['name'] as String,
        // Vehículos guardados antes de que existiera el tipo no tienen esta
        // clave en el JSON: se asumen turismo, el caso más habitual.
        type: VehicleType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => VehicleType.car,
        ),
        model: json['model'] as String? ?? '',
        year: (json['year'] as num?)?.toInt(),
      );
}
