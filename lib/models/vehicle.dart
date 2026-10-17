import 'vehicle_type.dart';

/// Un vehículo del usuario, para poder llevar el consumo de varios coches
/// (o motos) por separado en vez de mezclarlos todos en una sola media.
class Vehicle {
  Vehicle({
    required this.id,
    required this.name,
    this.type = VehicleType.car,
  });

  final String id;
  final String name;
  final VehicleType type;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'type': type.name};

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        name: json['name'] as String,
        // Vehículos guardados antes de que existiera el tipo no tienen esta
        // clave en el JSON: se asumen turismo, el caso más habitual.
        type: VehicleType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => VehicleType.car,
        ),
      );
}
