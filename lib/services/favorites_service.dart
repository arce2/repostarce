import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el propio dispositivo qué gasolineras (por su [GasStation.id],
/// el IDEESS) ha marcado el usuario como favoritas, para poder ver sus
/// precios en la pantalla de inicio sin repetir la búsqueda cada vez.
class FavoritesService {
  static const _prefsKey = 'favorite_station_ids';

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? const []).toSet();
  }

  Future<bool> isFavorite(String stationId) async {
    final ids = await getFavoriteIds();
    return ids.contains(stationId);
  }

  /// Añade o quita [stationId] de favoritas. Devuelve el nuevo estado
  /// (true si ha quedado marcada como favorita).
  Future<bool> toggleFavorite(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_prefsKey) ?? const []).toSet();
    final nowFavorite = ids.add(stationId);
    if (!nowFavorite) ids.remove(stationId);
    await prefs.setStringList(_prefsKey, ids.toList());
    return nowFavorite;
  }
}
