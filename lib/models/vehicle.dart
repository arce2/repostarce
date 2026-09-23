/// Un vehículo del usuario, para poder llevar el consumo de varios coches
/// (o motos) por separado en vez de mezclarlos todos en una sola media.
class Vehicle {
  Vehicle({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}
