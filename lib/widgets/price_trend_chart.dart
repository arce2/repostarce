import 'package:flutter/material.dart';

import '../services/price_history_service.dart';

/// Gráfico de línea simple (sin librería externa) con la evolución del
/// precio de una gasolinera+combustible en los últimos días.
class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({super.key, required this.points, required this.color});

  final List<PricePoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prices = points.map((p) => p.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${maxPrice.toStringAsFixed(3)} €',
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
              Text('${minPrice.toStringAsFixed(3)} €',
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomPaint(
              painter: _TrendPainter(
                prices: prices,
                color: color,
                gridColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.prices, required this.color, required this.gridColor});

  final List<double> prices;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final range = (maxPrice - minPrice).abs() < 0.001 ? 1.0 : maxPrice - minPrice;

    final dx = size.width / (prices.length - 1);
    Offset pointAt(int i) {
      final normalized = (prices[i] - minPrice) / range;
      final y = size.height - (normalized * size.height);
      return Offset(dx * i, y.clamp(0, size.height));
    }

    // Línea base (precio más reciente) para orientar la lectura.
    final basePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), basePaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < prices.length; i++) {
      final p = pointAt(i);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(pointAt(prices.length - 1), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.prices != prices || oldDelegate.color != color;
}
