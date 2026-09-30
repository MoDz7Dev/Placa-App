import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Envuelve la app y fuerza el estilo de las barras del sistema
/// (arriba y abajo) para TODAS las pantallas, sin repetirlo en cada una.
class AppSystemBars extends StatelessWidget {
  const AppSystemBars({super.key, required this.child});

  final Widget child;

  static const SystemUiOverlayStyle lightStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightStyle,
      child: child,
    );
  }
}
