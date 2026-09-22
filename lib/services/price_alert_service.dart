import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../l10n/gen/app_localizations.dart';

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
    required AppLocalizations l10n,
    required String stationId,
    required String brand,
    required double oldPrice,
    required double newPrice,
  }) async {
    await _ensureInitialized();
    final dropped = newPrice < oldPrice;
    final androidDetails = AndroidNotificationDetails(
      'price_changes',
      l10n.priceAlertChannelName,
      channelDescription: l10n.priceAlertChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    final displayBrand = brand.isNotEmpty ? brand : l10n.priceAlertFallbackBrand;
    final title = dropped
        ? l10n.priceAlertDropTitle(displayBrand)
        : l10n.priceAlertRiseTitle(displayBrand);
    await _plugin.show(
      stationId.hashCode & 0x7fffffff,
      title,
      l10n.priceAlertBody(
        newPrice.toStringAsFixed(3),
        oldPrice.toStringAsFixed(3),
      ),
      details,
    );
  }
}
