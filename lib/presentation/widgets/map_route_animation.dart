import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:placa_app/config/theme/app_theme.dart';

/// Mapa estilizado con una ruta entre un origen y un destino, más un
/// marcador que avanza a lo largo de la ruta según [progress] (0.0 → 1.0).
///
/// El progreso suele venir del desplazamiento del PageView, de forma que
/// el marcador se mueve "mientras se desliza" el carrusel.
class MapRouteAnimation extends StatelessWidget {
  /// Progreso del recorrido entre 0.0 (inicio) y 1.0 (llegada).
  final double progress;

  /// Color de acento de la ruta y los pines.
  final Color accentColor;

  const MapRouteAnimation({
    super.key,
    required this.progress,
    this.accentColor = kPrimaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Fondo del mapa + ruta.
              CustomPaint(
                size: size,
                painter: _MapPainter(
                  progress: progress.clamp(0.0, 1.0),
                  accentColor: accentColor,
                ),
              ),
              // Etiqueta del origen.
              const _AddressLabel(
                text: '123 Address Av, City.',
                alignment: Alignment(-0.55, 0.65),
              ),
              // Etiqueta del destino.
              const _AddressLabel(
                text: '123 Address Av, City.',
                alignment: Alignment(0.45, -0.35),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pequeña etiqueta blanca con sombra (estilo tarjeta) para las direcciones.
class _AddressLabel extends StatelessWidget {
  final String text;
  final Alignment alignment;

  const _AddressLabel({required this.text, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF4A4A68),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _MapPainter({required this.progress, required this.accentColor});

  // Puntos de control de la ruta en coordenadas relativas (0..1).
  static const List<Offset> _routePoints = [
    Offset(0.30, 0.78), // origen (abajo-izquierda)
    Offset(0.55, 0.62),
    Offset(0.45, 0.42),
    Offset(0.70, 0.28),
    Offset(0.72, 0.18), // destino (arriba-derecha)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintMapBackground(canvas, size);
    final routePath = _buildRoutePath(size);
    _paintRoute(canvas, routePath);
    _paintPins(canvas, size);
    _paintMovingMarker(canvas, routePath);
  }

  // --- Fondo tipo mapa ------------------------------------------------------

  void _paintMapBackground(Canvas canvas, Size size) {
    // Base.
    final base = Paint()..color = const Color(0xFFBFC7D1);
    canvas.drawRect(Offset.zero & size, base);

    // Manzanas de "calles" en gris claro.
    final block = Paint()..color = const Color(0xFFD6DBE1);
    const double gap = 6;

    // Rejilla de bloques ligeramente inclinada para dar sensación de mapa.
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.15);
    canvas.translate(-size.width * 0.7, -size.height * 0.7);

    const double cell = 52;
    for (double y = -cell; y < size.height * 1.6; y += cell + gap) {
      for (double x = -cell; x < size.width * 1.6; x += cell + gap) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cell, cell),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, block);
      }
    }
    canvas.restore();

    // Una calle diagonal más clara (avenida principal).
    final avenue = Paint()
      ..color = const Color(0xFFE7EAEE)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-size.width * 0.1, size.height * 0.9),
      Offset(size.width * 1.1, size.height * 0.1),
      avenue,
    );
  }

  // --- Ruta -----------------------------------------------------------------

  Path _buildRoutePath(Size size) {
    final path = ui.Path();
    for (var i = 0; i < _routePoints.length; i++) {
      final p = Offset(
        _routePoints[i].dx * size.width,
        _routePoints[i].dy * size.height,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }

  void _paintRoute(Canvas canvas, Path routePath) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ruta como línea segmentada (estilo punteado de la referencia).
    for (final metric in routePath.computeMetrics()) {
      double distance = 0;
      const double dash = 10;
      const double space = 6;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + space;
      }
    }
  }


  // --- Pines -----------------------------------------------------------------

  void _paintPins(Canvas canvas, Size size) {
    final origin = Offset(
      _routePoints.first.dx * size.width,
      _routePoints.first.dy * size.height,
    );
    final destination = Offset(
      _routePoints.last.dx * size.width,
      _routePoints.last.dy * size.height,
    );

    _drawPin(canvas, origin);
    _drawPin(canvas, destination, filled: true);
  }

  void _drawPin(Canvas canvas, Offset center, {bool filled = false}) {
    // Sombra sutil.
    canvas.drawCircle(
      center + const Offset(0, 2),
      9,
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );
    // Círculo del pin.
    canvas.drawCircle(center, 9, Paint()..color = accentColor);
    // Aro blanco.
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Punto blanco interior.
    canvas.drawCircle(center, filled ? 3 : 2.5, Paint()..color = Colors.white);
  }

  // --- Marcador que avanza ---------------------------------------------------

  void _paintMovingMarker(Canvas canvas, Path routePath) {
    for (final metric in routePath.computeMetrics()) {
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent == null) continue;

      final pos = tangent.position;
      // Sombra.
      canvas.drawCircle(
        pos + const Offset(0, 2),
        11,
        Paint()..color = Colors.black.withValues(alpha: 0.25),
      );
      // Aro blanco.
      canvas.drawCircle(pos, 11, Paint()..color = Colors.white);
      // Círculo de acento (el "punto" que avanza).
      canvas.drawCircle(pos, 7, Paint()..color = accentColor);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}

