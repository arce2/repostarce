import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_type.dart';
import '../models/gas_station.dart';
import '../models/loyalty_card.dart';

/// Guarda en el dispositivo las tarjetas de descuento del usuario (marca +
/// cuánto ahorra por litro), para poder mostrar el precio real que paga en
/// las gasolineras de esa marca, descuento ya incluido.
class LoyaltyCardService {
  static const _prefsKey = 'loyalty_cards_v1';

  Future<List<LoyaltyCard>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().map(LoyaltyCard.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCard(LoyaltyCard card) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await getCards();
    cards.removeWhere((c) => c.brand.toLowerCase() == card.brand.toLowerCase());
    cards.add(card);
    await prefs.setString(_prefsKey, jsonEncode(cards.map((c) => c.toJson()).toList()));
  }

  Future<void> removeCard(String brand) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await getCards();
    cards.removeWhere((c) => c.brand.toLowerCase() == brand.toLowerCase());
    await prefs.setString(_prefsKey, jsonEncode(cards.map((c) => c.toJson()).toList()));
  }

  /// Busca si alguna de [cards] aplica a la marca de [station] (comparación
  /// flexible: una tarjeta "Repsol" coincide con rótulos como "E.S. REPSOL").
  LoyaltyCard? cardFor(GasStation station, List<LoyaltyCard> cards) {
    final brand = station.brand.toLowerCase();
    for (final card in cards) {
      if (brand.contains(card.brand.toLowerCase())) return card;
    }
    return null;
  }

  /// Precio final tras aplicar el descuento de la tarjeta que corresponda
  /// (nunca por debajo de 0), o `null` si la estación no vende ese
  /// combustible o no hay ninguna tarjeta aplicable.
  double? effectivePrice(GasStation station, FuelType type, List<LoyaltyCard> cards) {
    final price = station.priceFor(type);
    if (price == null) return null;
    final card = cardFor(station, cards);
    if (card == null) return null;
    final effective = price - card.discountPerLiter;
    return effective < 0 ? 0 : effective;
  }
}
