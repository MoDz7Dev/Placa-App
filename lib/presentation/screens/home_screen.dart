import 'package:flutter/material.dart';
import 'package:placa_app/presentation/screens/botones_screen.dart';
import '../widgets/carousel_slider.dart';
import '../widgets/custom_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<SlideData> _slides = [
    SlideData(
      image: 'assets/images/auto_suzuki.png',
      title: 'Información rápida cuando más la necesitas',
      subtitle: 'Verifica antecedentes antes de comprar y obtén asistencia inmediata en caso de choque.',
      scale: 1.4,
      color: const Color(0xFF2C5282), // Azul oscuro
      xOffset: 20.0, // <--- Ajustado: Un poquito a la derecha
      yOffset: 0.0,
    ),
    SlideData(
      image: 'assets/images/auto_verde.png',
      title: 'Localiza tu vehículo al instante',
      subtitle: 'Sigue la ubicación de tu auto en tiempo real y mantén el control desde cualquier lugar.',
      scale: 0.9,
      color: const Color(0xFF7CB342), // Verde claro
      xOffset: -10.0, // <--- Ajustado: Un poquito a la izquierda
      yOffset: 0.0,
    ),
    SlideData(
      image: 'assets/images/auto_blanco.png',
      title: 'Conoce el estado de tu auto',
      subtitle: 'Revisa el historial de mantenimiento y el estado actual de tu vehículo con un solo toque.',
      scale: 1.0, // <--- CAMBIO: Bajado de 0.8 a 0.6 para que se vea más pequeño
      color: const Color(0xFFE0E0E0), 
      xOffset: 0.0, // <--- CAMBIO: Movido a la DERECHA (positivo) para centrarlo
      yOffset: 0.0,
    ),
  ];

  int _currentIndex = 0;

  void _onPageChanged(int index, Color color) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _slides[_currentIndex].color;

    return Scaffold(
      backgroundColor: const Color(0xFF22252a),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Color.lerp(const Color(0xFF22252a), currentColor, 0.15),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: CarouselSlider(
                  slides: _slides,
                  onPageChanged: _onPageChanged,
                ),
              ),
              CustomActionButton(
                color: currentColor,
                text: '¡Estoy listo!',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.push(
                          context,
                            MaterialPageRoute(
                              builder: (context) => OptionsScreen(baseColor: currentColor), // <--- Le pasamos el color
                              ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}