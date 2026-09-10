import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Muestra una notificación del sistema cuando baja el precio de una
/// gasolinera favorita.
///
/// Importante: la app no tiene servidor ni tareas en segundo plano, así
/// que la comprobación se hace cuando se abre la app (en [HomeScreen]),
/// no al instante en que cambia el precio real. Avisa "la próxima vez que
/// abras Repostarce", no en tiempo real.
class PriceAlertService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> notifyPriceDrop({
    required String stationId,
    required String brand,
    required double oldPrice,
    required double newPrice,
  }) async {
    await _ensureInitialized();
    const androidDetails = AndroidNotificationDetails(
      'price_drops',
      'Bajadas de precio',
      channelDescription:
          'Avisa cuando baja el precio de una gasolinera favorita',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      stationId.hashCode & 0x7fffffff,
      '¡Bajó el precio en ${brand.isNotEmpty ? brand : "tu favorita"}!',
      'Ahora a ${newPrice.toStringAsFixed(3)} € (antes ${oldPrice.toStringAsFixed(3)} €)',
      details,
    );
  }
}
