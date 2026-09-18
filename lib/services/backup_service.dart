import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Claves de `shared_preferences` que guardan datos personales del
/// usuario (no las de caché, esas no hace falta respaldarlas).
const _backupKeys = [
  'favorite_station_ids',
  'price_history_v1',
  'fuel_log_v1',
  'loyalty_cards_v1',
];

/// Exporta e importa todos los datos personales que la app guarda solo en
/// el dispositivo (favoritas, histórico de precios, repostajes y tarjetas
/// de descuento), para poder hacer una copia de seguridad o pasarlos a
/// otro móvil.
class BackupService {
  /// Genera el JSON con una copia de todos los datos guardados ahora
  /// mismo en el dispositivo.
  Future<String> buildBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final key in _backupKeys) {
      final value = prefs.get(key);
      if (value == null) continue;
      if (value is List<String>) {
        data[key] = {'type': 'stringList', 'value': value};
      } else if (value is String) {
        data[key] = {'type': 'string', 'value': value};
      }
    }
    final backup = {
      'app': 'Repostarce',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  /// Restaura una copia generada por [buildBackupJson], sobrescribiendo
  /// los datos que haya ahora mismo en el dispositivo.
  Future<void> restoreFromJson(String jsonString) async {
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException(
        'El archivo elegido no es un JSON válido.',
      );
    }
    final data = decoded['data'];
    if (decoded['app'] != 'Repostarce' || data is! Map<String, dynamic>) {
      throw const FormatException(
        'El archivo no es una copia de seguridad de Repostarce.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    for (final entry in data.entries) {
      if (!_backupKeys.contains(entry.key)) continue;
      final field = entry.value as Map<String, dynamic>;
      final type = field['type'] as String?;
      if (type == 'stringList') {
        await prefs.setStringList(entry.key, (field['value'] as List).cast<String>());
      } else if (type == 'string') {
        await prefs.setString(entry.key, field['value'] as String);
      }
    }
  }
}
