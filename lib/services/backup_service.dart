import 'package:shared_preferences/shared_preferences.dart';

/// Exporta e importa todos los datos locales de la app (vehículos,
/// repostajes con sus datos de facturación, favoritas, histórico de
/// precios e idioma) como un único archivo JSON.
///
/// No reconstruye los modelos: copia tal cual las claves de
/// SharedPreferences que ya usa cada servicio, para no duplicar lógica de
/// (de)serialización ni arriesgarse a que un cambio futuro en un modelo
/// deje el backup desincronizado respecto al servicio real.
class BackupService {
  static const schemaVersion = 1;
  static const _appId = 'Gasly';

  static const _stringKeys = [
    'fuel_log_v1',
    'app_locale',
    'vehicles_v1',
    'active_vehicle_v1',
    'price_history_v1',
    'trip_speed_log_v1',
  ];

  static const _stringListKeys = ['favorite_station_ids'];

  Future<Map<String, dynamic>> buildExport() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final key in _stringKeys) {
      final value = prefs.getString(key);
      if (value != null) data[key] = value;
    }
    for (final key in _stringListKeys) {
      final value = prefs.getStringList(key);
      if (value != null) data[key] = value;
    }
    return {
      'app': _appId,
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
  }

  /// Lanza [FormatException] si [json] no tiene la forma de un backup de
  /// Gasly (p. ej. si el usuario elige por error un archivo que no es este).
  Future<void> restoreImport(Map<String, dynamic> json) async {
    if (json['app'] != _appId || json['data'] is! Map) {
      throw const FormatException('No es un archivo de copia de Gasly');
    }
    final data = (json['data'] as Map).cast<String, dynamic>();
    final prefs = await SharedPreferences.getInstance();
    for (final entry in data.entries) {
      final value = entry.value;
      if (_stringListKeys.contains(entry.key) && value is List) {
        await prefs.setStringList(entry.key, value.cast<String>());
      } else if (value is String) {
        await prefs.setString(entry.key, value);
      }
    }
  }
}
