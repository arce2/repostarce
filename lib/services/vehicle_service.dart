import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle.dart';

/// Guarda los vehículos del usuario y cuál está activo ahora mismo (el que
/// se usa para registrar repostajes y para estimar el coste de un
/// trayecto). Siempre hay al menos un vehículo: si no se ha creado
/// ninguno, se genera uno por defecto con id fijo 'default' y nombre
/// vacío (la interfaz lo muestra con un nombre localizado tipo "Mi coche").
class VehicleService {
  static const _vehiclesKey = 'vehicles_v1';
  static const _activeVehicleKey = 'active_vehicle_v1';
  static const defaultVehicleId = 'default';

  Future<List<Vehicle>> getVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehiclesKey);
    if (raw == null || raw.isEmpty) {
      final defaultVehicle = Vehicle(id: defaultVehicleId, name: '');
      await _save(prefs, [defaultVehicle]);
      return [defaultVehicle];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final vehicles =
          list.cast<Map<String, dynamic>>().map(Vehicle.fromJson).toList();
      if (vehicles.isEmpty) {
        final defaultVehicle = Vehicle(id: defaultVehicleId, name: '');
        await _save(prefs, [defaultVehicle]);
        return [defaultVehicle];
      }
      return vehicles;
    } catch (_) {
      final defaultVehicle = Vehicle(id: defaultVehicleId, name: '');
      await _save(prefs, [defaultVehicle]);
      return [defaultVehicle];
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final vehicles = await getVehicles();
    vehicles.add(vehicle);
    final prefs = await SharedPreferences.getInstance();
    await _save(prefs, vehicles);
  }

  /// No deja borrar el último vehículo que quede: siempre debe haber uno.
  Future<void> deleteVehicle(String id) async {
    final vehicles = await getVehicles();
    if (vehicles.length <= 1) return;
    vehicles.removeWhere((v) => v.id == id);
    final prefs = await SharedPreferences.getInstance();
    await _save(prefs, vehicles);
    if (await getActiveVehicleId() == id) {
      await setActiveVehicleId(vehicles.first.id);
    }
  }

  Future<void> _save(SharedPreferences prefs, List<Vehicle> vehicles) async {
    await prefs.setString(
        _vehiclesKey, jsonEncode(vehicles.map((v) => v.toJson()).toList()));
  }

  Future<String> getActiveVehicleId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_activeVehicleKey);
    if (id != null) return id;
    final vehicles = await getVehicles();
    return vehicles.first.id;
  }

  Future<void> setActiveVehicleId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeVehicleKey, id);
  }
}
