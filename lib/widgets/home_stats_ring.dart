import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';
import '../theme/app_theme.dart';
import 'animated_number_text.dart';

/// Panel circular que sustituye a la ilustración de bienvenida: muestra de
/// un vistazo el gasto del mes, el ahorro estimado frente a la media
/// nacional, y cuándo fue (o tocaría) el próximo repostaje a cada lado.
class HomeStatsRing extends StatelessWidget {
  const HomeStatsRing({
    super.key,
    required this.monthlySpend,
    required this.monthlySavings,
    required this.lastFillUpDate,
    required this.nextFillUpEstimate,
  });

  final double? monthlySpend;
  final double? monthlySavings;
  final DateTime? lastFillUpDate;
  final DateTime? nextFillUpEstimate;

  String _relativePast(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return l10n.homeStatsToday;
    if (days == 1) return l10n.homeStatsYesterday;
    return l10n.homeStatsDaysAgo(days);
  }

  String _relativeFuture(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final days = date.difference(DateTime.now()).inDays;
    if (days <= 0) return l10n.homeStatsAnyDayNow;
    return l10n.homeStatsDaysUntil(days);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SideStat(
          icon: Icons.history_rounded,
          label: l10n.homeStatsLastFillUp,
          value: lastFillUpDate != null
              ? _relativePast(context, lastFillUpDate!)
              : l10n.homeStatsNoData,
        ),
        const SizedBox(width: 10),
        _Ring(
          monthlySpend: monthlySpend,
          monthlySavings: monthlySavings,
        ),
        const SizedBox(width: 10),
        _SideStat(
          icon: Icons.event_outlined,
          label: l10n.homeStatsNextFillUp,
          value: nextFillUpEstimate != null
              ? _relativeFuture(context, nextFillUpEstimate!)
              : l10n.homeStatsNoData,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.monthlySpend, required this.monthlySavings});

  final double? monthlySpend;
  final double? monthlySavings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    const ringSize = 148.0;
    const ringThickness = 6.0;
    final savings = monthlySavings;
    final isSaving = savings != null && savings > 0.01;
    final isLosing = savings != null && savings < -0.01;

    return Container(
      width: ringSize,
      height: ringSize,
      padding: const EdgeInsets.all(ringThickness),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            AppTheme.seedColor,
            Color(0xFFFFB199),
            AppTheme.cheapestColor,
            AppTheme.seedColor,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.surface),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeStatsMonthlySpendLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              monthlySpend != null
                  ? AnimatedNumberText(
                      value: monthlySpend!,
                      formatter: (v) => '${v.toStringAsFixed(0)} €',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
                    )
                  : Text('—',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: colorScheme.onSurfaceVariant)),
              if (isSaving || isLosing) ...[
                const SizedBox(height: 4),
                Text(
                  isSaving
                      ? l10n.homeStatsSavingLabel(savings.abs().toStringAsFixed(0))
                      : l10n.homeStatsOverpayingLabel(savings.abs().toStringAsFixed(0)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSaving ? AppTheme.cheapestColor : AppTheme.mostExpensiveColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SideStat extends StatelessWidget {
  const _SideStat({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.onSurfaceVariant;
    return SizedBox(
      width: 74,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: accent),
          ),
        ],
      ),
    );
  }
}
