import 'package:flutter/material.dart';

const _mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Gráfica de línea sencilla con la evolución de precio de un combustible
/// en una gasolinera concreta, a partir del histórico guardado en el
/// dispositivo. Una sola serie: usa el color de marca de la app, sin
/// leyenda (el título de la sección ya dice qué es).
class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({super.key, required this.points});

  /// Puntos ordenados de más antiguo a más reciente. Debe tener al menos 2.
  final List<MapEntry<DateTime, double>> points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prices = points.map((p) => p.value).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 108,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendPainter(
              prices: prices,
              lineColor: colorScheme.primary,
              fillColor: colorScheme.primary.withValues(alpha: 0.12),
              labelColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatShort(points.first.key),
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
            Text(
              _formatShort(points.last.key),
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  String _formatShort(DateTime d) => '${d.day} ${_mesesCortos[d.month - 1]}';
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.prices,
    required this.lineColor,
    required this.fillColor,
    required this.labelColor,
  });

  final List<double> prices;
  final Color lineColor;
  final Color fillColor;
  final Color labelColor;

  static const _labelSpace = 34.0;

  @override
  void paint(Canvas canvas, Size size) {
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final range = (maxPrice - minPrice).abs() < 0.001 ? 1.0 : maxPrice - minPrice;
    final chartHeight = size.height - _labelSpace - 6;

    double xFor(int i) =>
        prices.length > 1 ? size.width * i / (prices.length - 1) : size.width / 2;
    double yFor(double price) =>
        _labelSpace + chartHeight - ((price - minPrice) / range) * chartHeight;

    final linePath = Path();
    final fillPath = Path();
    for (var i = 0; i < prices.length; i++) {
      final x = xFor(i);
      final y = yFor(prices[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, _labelSpace + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(xFor(prices.length - 1), _labelSpace + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(Offset(xFor(0), yFor(prices.first)), 3.2, Paint()..color = lineColor);
    canvas.drawCircle(
      Offset(xFor(prices.length - 1), yFor(prices.last)),
      3.2,
      Paint()..color = lineColor,
    );

    void drawLabel(int index, String text) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (xFor(index) - tp.width / 2).clamp(0.0, size.width - tp.width);
      final y = (yFor(prices[index]) - tp.height - 6).clamp(0.0, size.height - tp.height);
      tp.paint(canvas, Offset(x, y));
    }

    if (maxPrice - minPrice >= 0.001) {
      drawLabel(prices.indexOf(maxPrice), '${maxPrice.toStringAsFixed(3)} €');
      drawLabel(prices.indexOf(minPrice), '${minPrice.toStringAsFixed(3)} €');
    } else {
      drawLabel(0, '${prices.first.toStringAsFixed(3)} €');
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.prices != prices || oldDelegate.lineColor != lineColor;
}
