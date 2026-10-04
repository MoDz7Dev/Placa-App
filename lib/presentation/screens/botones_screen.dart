import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'placa_entry_screen.dart';

class OptionsScreen extends StatelessWidget {
  final Color baseColor;

  const OptionsScreen({super.key, required this.baseColor});

  // --- Paleta del diseño ---
  static const Color _cream = Color(0xff3e4044);
  static const Color _white = Color(0xFFFFFFFF); // tarjeta 1
  static const Color _blue = Color(0xFF2451B2); // tarjeta 2
  static const Color _navy = Color(0xFF1E3A5F); // texto oscuro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- Barra superior con botón atrás ---
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: _navy),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // --- Tarjetas grandes ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 8, 30, 36),
                    child: Column(
                      children: [
                        // Tarjeta 1: Escanear (blanca, foto de manos con celular)
                        Expanded(
                          child: _OptionCard(
                            color: _white,
                            text: 'ESCANEAR\nPLACA',
                            image: 'assets/images/scan_mano_auto.jpg',
                            imageAlignment: const Alignment(0.0, 0.1),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScanScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Tarjeta 2: Escribir (azul, foto de manos con celular)
                        Expanded(
                          child: _OptionCard(
                            color: _blue,
                            text: 'BUSCAR POR\nINFORMACION',
                            image: 'assets/images/celular_mano.jpg',
                            imageAlignment: const Alignment(0.0, -0.1),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlateEntryScreen(
                                    baseColor: baseColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta grande con una foto (enfocada en las manos) que se desvanece
/// de arriba hacia abajo hacia el color de la tarjeta, y texto abajo.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.color,
    required this.text,
    required this.image,
    required this.onPressed,
    this.imageAlignment = Alignment.center,
  });

  final Color color;
  final String text;
  final String image;
  final VoidCallback onPressed;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    // Texto oscuro sobre fondo claro (blanco) y blanco sobre fondo oscuro (azul).
    final bool isDarkColor = color.computeLuminance() < 0.5;
    final Color contentColor = isDarkColor ? Colors.white : OptionsScreen._navy;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Material(
        color: color,
        child: InkWell(
          onTap: onPressed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- Foto enfocada en las manos ---
              Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: imageAlignment,
              ),

              // --- Fade de desvanecimiento de arriba hacia abajo ---
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 0.78],
                    colors: [
                      color.withValues(alpha: 0.0),
                      color.withValues(alpha: 0.55),
                      color,
                    ],
                  ),
                ),
              ),

              // --- Texto grande ---
              Positioned(
                left: 26,
                right: 26,
                bottom: 26,
                child: Text(
                  text,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 36,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




