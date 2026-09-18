/// Una tarjeta de descuento/fidelización de una petrolera (Repsol Club,
/// Cepsa, etc.): la marca a la que aplica y cuánto ahorra por litro.
class LoyaltyCard {
  LoyaltyCard({required this.brand, required this.discountPerLiter});

  final String brand;
  final double discountPerLiter;

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        brand: json['brand'] as String,
        discountPerLiter: (json['discountPerLiter'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'discountPerLiter': discountPerLiter,
      };
}
