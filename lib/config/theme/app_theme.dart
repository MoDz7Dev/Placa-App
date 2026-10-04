import 'package:flutter/material.dart';

/// Color base azulado de la app (tono de fondo del primer slide).
const Color kPrimaryBlue = Color(0xFF2451B2);
const Color kSecondaryBlue = Color(0xFF32426A);

/// Fondo oscuro azulado de las pantallas.
const Color kDarkBackground = Color(0xFF1B2A3A);

class AppTheme {
  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kDarkBackground,
      // Esquema azulado generado a partir del color del primer slide.
      // Nota: no se puede usar colorSchemeSeed Y colorScheme a la vez.
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryBlue,
        brightness: Brightness.dark,
        surface: kDarkBackground,
      ),
    );
  }
}