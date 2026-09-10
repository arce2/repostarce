import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Muestra una notificación del sistema cuando cambia (sube o baja) el
/// precio de una gasolinera favorita.
///
/// La app no tiene servidor propio, así que no hay forma de avisar en el
/// instante exacto en que cambia el precio real. Para acercarnos lo más
/// posible a "en cuanto cambie", la comprobación se repite: al abrir la
/// app, al volver a ella desde segundo plano, y cada pocos minutos
/// mientras se tiene abierta (ver los "refresh" periódicos en
/// [HomeScreen] y [ResultsScreen]).
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

  /// Avisa de que el precio de una favorita ha cambiado desde la última
  /// vez que se comprobó, tanto si ha bajado como si ha subido.
  Future<void> notifyPriceChange({
    required String stationId,
    required String brand,
    required double oldPrice,
    required double newPrice,
  }) async {
    await _ensureInitialized();
    final dropped = newPrice < oldPrice;
    const androidDetails = AndroidNotificationDetails(
      'price_changes',
      'Cambios de precio',
      channelDescription:
          'Avisa cuando sube o baja el precio de una gasolinera favorita',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    final title = dropped
        ? '¡Bajó el precio en ${brand.isNotEmpty ? brand : "tu favorita"}!'
        : 'Subió el precio en ${brand.isNotEmpty ? brand : "tu favorita"}';
    await _plugin.show(
      stationId.hashCode & 0x7fffffff,
      title,
      'Ahora a ${newPrice.toStringAsFixed(3)} € (antes ${oldPrice.toStringAsFixed(3)} €)',
      details,
    );
  }
}
