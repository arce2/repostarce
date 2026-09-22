import 'package:flutter/material.dart';

/// Tema visual compartido por toda la app.
///
/// Naranja-rojo (a juego con la mascota zorro del logo) como color de
/// marca sobre fondos negros, y ámbar/rojo como acento semántico
/// reservado para destacar el mejor y el peor precio (no son colores de
/// marca, así que no cambian con ella).
class AppTheme {
  AppTheme._();

  static const seedColor = Color(0xFFE8442A);
  static const cheapestColor = Color(0xFFC77B00);
  static const mostExpensiveColor = Color(0xFFC0392B);

  /// Fondo "negro" real para el tema oscuro: el tono oscuro que genera
  /// Material 3 a partir de la semilla no llega a ser negro puro, así que
  /// se sobrescriben aquí los tonos de superficie.
  static const _trueBlack = Color(0xFF000000);
  static const _nearBlack1 = Color(0xFF0A0A0A);
  static const _nearBlack2 = Color(0xFF121212);
  static const _nearBlack3 = Color(0xFF1A1A1A);
  static const _nearBlack4 = Color(0xFF222222);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    if (brightness == Brightness.dark) {
      colorScheme = colorScheme.copyWith(
        surface: _trueBlack,
        surfaceContainerLowest: _trueBlack,
        surfaceContainerLow: _nearBlack1,
        surfaceContainer: _nearBlack2,
        surfaceContainerHigh: _nearBlack3,
        surfaceContainerHighest: _nearBlack4,
        // Material aclara mucho el color de marca en modo oscuro por
        // accesibilidad; aquí se fuerza el naranja-rojo vivo del logo en
        // vez del tono pastel automático.
        primary: seedColor,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF7A2415),
        onPrimaryContainer: const Color(0xFFFFD9CC),
      );
    }
    final radius16 = BorderRadius.circular(16);
    final radius20 = BorderRadius.circular(20);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: radius20),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide.none),
        enabledBorder:
            OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius16,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.outlineVariant),
        color: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerLow;
        }),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius20),
        tileColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
