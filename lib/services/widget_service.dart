import 'package:home_widget/home_widget.dart';

import '../models/gas_station.dart';

/// Escribe en el widget de pantalla de inicio (Android) la gasolinera más
/// barata que la app ha visto la última vez, en primer plano. No hay
/// tareas en segundo plano: el widget no se actualiza solo, se actualiza
/// cada vez que la app carga precios (ver [ResultsScreen] y [HomeScreen]).
class WidgetService {
  static const _androidProviderName = 'CheapestPriceWidgetProvider';

  Future<void> updateCheapest(GasStation station, double price) async {
    final brand = station.brand.isNotEmpty ? station.brand : '—';
    await HomeWidget.saveWidgetData<String>('widget_station_name', brand);
    await HomeWidget.saveWidgetData<String>(
        'widget_price', '${price.toStringAsFixed(3)} €');
    await HomeWidget.saveWidgetData<String>(
        'widget_updated_at', _formatNow());
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }

  String _formatNow() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
