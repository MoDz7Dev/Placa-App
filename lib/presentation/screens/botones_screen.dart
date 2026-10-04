import 'package:flutter/material.dart';
import '../widgets/custom_action_button.dart';
import 'scan_screen.dart';
import 'placa_entry_screen.dart'; 

class OptionsScreen extends StatelessWidget {
  final Color baseColor; 

  const OptionsScreen({super.key, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Color.lerp(const Color(0xFF22252a), baseColor, 0.15),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      '¿Cómo quieres buscar?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón 1: Escanear
                      CustomActionButton(
                        color: baseColor, 
                        text: 'Escanear Placa',
                        icon: Icons.qr_code_scanner,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScanScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 10),

                      // Botón 2: Escribir
                      CustomActionButton(
                        color: baseColor, // <--- AHORA TAMBIÉN CAMBIA DE COLOR
                        text: 'Escribir Placa',
                        icon: Icons.keyboard_alt_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PlateEntryScreen(baseColor: baseColor)),
                          );
                        },
                      ),
                    ],
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